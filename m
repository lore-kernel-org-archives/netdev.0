From: Andi Kleen <ak@suse.de>
Subject: Re: How can we make more use of memory for TCP properly?
Date: Wed, 14 Jun 2006 07:20:20 +0200
Message-ID: <200606140720.20504.ak@suse.de>
References: <448F323A.7000005@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57537 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S964879AbWFNFUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 01:20:24 -0400
To: Kumiko Ono <kumiko@cs.columbia.edu>
In-Reply-To: <448F323A.7000005@cs.columbia.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> Accorting to TCP man page, the kernel calculates the values of 
> sysctl_tcp_mem depending on available physical memory at boot time.
> I added 2GB RAM to a machine that had 2GB, and then it has 4GB RAM now. 
> However, the value of sysctl_tcp_mem[2] has not changed from 196608 
> (pages). The machine is running at Linux 2.6.16.5 i686 Intel(R) 
> Pentium(R) 4 CPU 3.06GHz.

TCP can only use low memory for this which is limited to around 900MB 
on 32bit systems. 64bit CPUs don't have this problem.

-Andi
