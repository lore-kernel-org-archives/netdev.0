From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Wed, 16 Apr 2003 03:07:10 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030416.030710.19512552.yoshfuji@linux-ipv6.org>
References: <20030414095030.50ad9652.rddunlap@osdl.org>
	<20030415.021728.70559400.yoshfuji@linux-ipv6.org>
	<20030415093442.0913486d.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com,
	usagi-core@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: rddunlap@osdl.org
In-Reply-To: <20030415093442.0913486d.rddunlap@osdl.org>
List-Id: netdev.vger.kernel.org

In article <20030415093442.0913486d.rddunlap@osdl.org> (at Tue, 15 Apr 2003 09:34:42 -0700), "Randy.Dunlap" <rddunlap@osdl.org> says:

> Do you have any updates (recommendations) on how to proceed on this?
> Have you looked at my patch file?

Yes.  I looked at the patch.
I also learned about seqfile.
Now I'm typing procfs seqfile part.
I'll send you my (uncompleted) patch.

I think per-cpu * per-interface.
and, I believe statictics should be held in inet6_dev{}.
We need ipv6 part, too.  Would you work on this?
(I don't have enough time to complete this in April...)


> I think that we can make some progress without having an answer to
> your question about /proc/sys/net/ipv6/conf/foobar file renaming.

Sure.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
