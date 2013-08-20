From: "Berg, Johannes" <johannes.berg@intel.com>
Subject: RE: [PATCH next] netlink: prevent deadlock in ctrl_dumpfamily()
Date: Tue, 20 Aug 2013 14:03:25 +0000
Message-ID: <1DC40B07CD6EC041A66726C271A73AE61AA6F1BC@IRSMSX102.ger.corp.intel.com>
References: <20130820135033.GA2315@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130820135033.GA2315@swordfish.minsk.epam.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> +	if (need_locking) {
> +		/* genl_mutex could be already locked in genl_rcv_msg() */
> +		rt = genl_family_find_byid(cb->nlh->nlmsg_type);
> +		need_locking = need_locking && rt->parallel_ops;
> +	}

This is equivalent to reverting the patch because parallel_ops will be false for the genl family. :-)

johannes
-- 

Intel GmbH
Dornacher Strasse 1
85622 Feldkirchen/Muenchen, Deutschland
Sitz der Gesellschaft: Feldkirchen bei Muenchen
Geschaeftsfuehrer: Christian Lamprechter, Hannes Schwaderer, Douglas Lusk
Registergericht: Muenchen HRB 47456
Ust.-IdNr./VAT Registration No.: DE129385895
Citibank Frankfurt a.M. (BLZ 502 109 00) 600119052
