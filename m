From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] hyperv: Add support for Virtual Receive Side
 Scaling (vRSS)
Date: Thu, 19 Dec 2013 22:05:44 +0000
Message-ID: <1387490744.1876.52.camel@bwh-desktop.uk.level5networks.com>
References: <1387405262-18334-1-git-send-email-haiyangz@microsoft.com>
 <1387475178.1876.29.camel@bwh-desktop.uk.level5networks.com>
 <ff7f7541d0164d408b3a4278569c593a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <52B33EC1.5040901@redhat.com>
 <6ee28c6a94e74c958ee96c3547741fb9@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <CA+mtBx-BBBQjVTOrnaow=GNc7VM5D2Zj8xr=fPM4b4f_xT7qkQ@mail.gmail.com>
 <05be4f23ff784e56b710dd02eb88358a@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
 <CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-12-19 at 13:43 -0800, Tom Herbert wrote:
> Patch is below. This version did most pre-computation of the variants
> I built, but results in largest table (40*256*4 bytes), This gives
> performance roughly comparable with jhash (roughly same as jhash for
> IPv4, about 30% more cycles for IPv6). I have the simpler less memory
> intensive versions also if you're interested, these are 10x worse
> cycles so I wouldn't want those in critical path.
> ----
> Introduce Toeplitz hash functions. Toeplitz is a hash used primarily in
> NICs to performan RSS flow steering.  This is a software implemenation
> of that. In order to make the hash calculation efficient, we precompute
> the possible hash values for each inidividual byte of input. The input
> length is up to 40 bytes, so we make an array of cache[40][256].
[...]

You haven't addressed my comments here:
<http://article.gmane.org/gmane.linux.network/284753>

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
