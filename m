From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [PATCH 0/7] [S390]: Introduction of AF_IUCV sockets support
Date: Fri, 9 Feb 2007 20:15:33 +0100
Message-ID: <20070209191533.GA25570@de.ibm.com>
References: <20070202120528.GA10392@de.ibm.com> <20070208.140022.45514241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:1231 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992767AbXBITQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 14:16:25 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l19JGOxQ057208
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:16:24 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l19JGOKS1900726
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:16:24 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l19JGNEq005137
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:16:23 GMT
Content-Disposition: inline
In-Reply-To: <20070208.140022.45514241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 02:00:22PM -0800, David Miller wrote:
> From: Frank Pavlic <fpavlic@de.ibm.com>
> Date: Fri, 2 Feb 2007 13:05:28 +0100
>  
> > The patch set consists of following patches:
> > 
> > [1/7] [S390]: Rewrite of the IUCV base code, part 1
> > [2/7] [S390]: Rewrite of the IUCV base code, part 2
> > [3/7] [S390]: Adapt monreader driver to new IUCV API
> > [4/7] [S390]: Adapt vmlogrdr driver to new IUCV API
> > [5/7] [S390]: Adapt netiucv driver to new IUCV API
> > [6/7] [S390]: Adapt special message interface to new IUCV API
> > [7/7] [S390]: Add AF_IUCV socket support
>  
> I've applied all of this, although some of the driver
> conversions (notable, patches #5 and #6) didn't apply
> cleanly so I applied them by hand.
Thanks for this , I figured that out today by myself and started
to make a new set of patches. You saved me a lot of time and work 
once again ;-)

>  
> Watch out for any fallout from this when Linus pulls
> these changes in.
> 
> Thanks.

I'll do so ...


