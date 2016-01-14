From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 14 Jan 2016 17:53:04 +0000
Message-ID: <20160114175304.161ff0af@lxorguk.ukuu.org.uk>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <20160110.172558.367101858392871618.davem@davemloft.net>
 <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <CALx6S35PbTHF7nY0ugtxCUkc5kUmMYAyuy6ZM34bZ9v42nDudg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CALx6S35PbTHF7nY0ugtxCUkc5kUmMYAyuy6ZM34bZ9v42nDudg@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> These results for Toeplitz are not plausible. Given random input you
> cannot expect any hash function to produce such uniform results. I
> suspect either your input data is biased or how your applying the hash
> is.
> 
> When I run 64 random IPv4 3-tuples through Toeplitz and Jenkins I get
> something more reasonable:

IPv4 address patterns are not random. Nothing like it. A long long time
ago we did do a bunch of tuning for network hashes using big porn site
data sets. Random it was not.

It's probably hard to repeat that exercise now with geo specific routing,
and all the front end caches and redirectors on big sites but I'd
strongly suggest random input is not a good test, and also that you need
to worry more about hash attacks than perfect distributions.

Alan
