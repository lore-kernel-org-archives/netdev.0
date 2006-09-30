From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: 2.6.18-mm2 - oops in cache_alloc_refill()
Date: Fri, 29 Sep 2006 18:40:43 -0700
Message-ID: <20060930014043.GA10927@bougret.hpl.hp.com>
References: <20060928014623.ccc9b885.akpm@osdl.org> <200609290319.k8T3JOwS005455@turing-police.cc.vt.edu> <20060928202931.dc324339.akpm@osdl.org> <200609291519.k8TFJfvw004256@turing-police.cc.vt.edu> <20060929124558.33ef6c75.akpm@osdl.org> <200609300001.k8U01sPI004389@turing-police.cc.vt.edu> <20060929182008.fee2a229.akpm@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valdis.Kletnieks@vt.edu,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:55265 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1422877AbWI3BpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 21:45:06 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060929182008.fee2a229.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2006 at 06:20:08PM -0700, Andrew Morton wrote:
> On Fri, 29 Sep 2006 20:01:54 -0400
> > 
> > A quick strace of gkrellm finds these likely ioctl's causing the problem:
> > 
> > % grep ioctl /tmp/foo2 | sort -u | more
> > ioctl(13, SIOCGIWESSID, 0xbfbcdb9c)     = 0
> > ioctl(13, SIOCGIWRANGE, 0xbfbcdbdc)     = 0
> > ioctl(13, SIOCGIWRATE, 0xbfbcdbbc)      = 0

	Excuse me, can you point out wich version of gkrellm you use
and where to find it, the only version that is listed on my page does
not use the ESSID ioctl. I want to be sure I'm looking at the same
thing as you are...

	Jean
