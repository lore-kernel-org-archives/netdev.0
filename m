From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4] Pull request for 'ipg-fixes' branch
Date: Sat, 12 Jan 2008 17:48:35 -0500
Message-ID: <478943C3.2010805@garzik.org>
References: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux@horizon.com,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40344 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759350AbYALWsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:48:41 -0500
In-Reply-To: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Please pull from branch 'ipg-fixes' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git ipg-fixes
> 
> to get the changes below.
> 
> I have tested the driver with a PIV HT based motherboard. The network
> controller is connected to a fast ethernet switch (yeah, I'm cheap).
> A second host is performing two loop of scp in both direction for a
> 400Mb file. The files are sha1sumed after each scp. I have added a
> 'ping -q -f -l16' from the computer under test after some time.
> 
> After 35 copies from the computer under test and 28 copies to it
> (the ping eats a bit):
>              total       used       free     shared    buffers     cached
> Mem:       1019040    1003860      15180          0      20556     936792
> -/+ buffers/cache:      46512     972528
> Swap:      2031608          0    2031608
> 
> Before:
>              total       used       free     shared    buffers     cached
> Mem:       1019040     572036     447004          0      14988     525924
> -/+ buffers/cache:      31124     987916
> Swap:      2031608          0    2031608
> 
> /proc/slabinfo before and after the test are attached.
> 
> The driver is still a POMS but it seems better now.
> 
> I will not be available to work further on this issue before sunday.
> I'd appreciate being Cced though.
> 
> Distance from 'net-2.6/master' (27d1cba21fcc50c37eef5042c6be9fa7135e88fc)
> -------------------------------------------------------------------------
> 
> 286c83ce6e8263a5c4c55a57b4c1040800de0171
> d42f3afc953f9c99ffe84667a3ecf0d3b69f3d64
> 358bf4b8e8cbde5d6411b219e93a61728c892685
> a58cceed4464ba8ae94294184c15f43e92a5de89
> 
> Diffstat
> --------
> 
>  drivers/net/ipg.c |   36 ++++++++++++------------------------
>  1 files changed, 12 insertions(+), 24 deletions(-)

hrm... tried to pull this, but received non-ipg stuff too


