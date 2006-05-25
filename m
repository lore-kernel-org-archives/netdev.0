From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Fri, 26 May 2006 02:24:19 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605260219270.13718@math.ut.ee>
References: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
 <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Pekka Savola <pekkas@netcore.fi>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:44482 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S965189AbWEYXYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 19:24:55 -0400
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(To YOSHIFUJI Hideaki: this is about the
http://comments.gmane.org/gmane.linux.network/35262 thread)

Tracked it down to IPV6 merge at 2006-03-21:
commit cd85f6e2f58282186ad720fc18482be228f0b972 is good (right before 
the bunch of patches)
commit b00055aacdb172c05067612278ba27265fcd05ce is bad (right after the 
bunch of changes)

http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=shortlog;h=705af309505681f197f81618440954d10f120dc0;pg=44 
shows the list of committs at that range.

-- 
Meelis Roos (mroos@linux.ee)
