From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH NEXT 1/5] staging: r8188eu: Fix sparse warnings in
 ioctl_linux.c
Date: Thu, 24 Oct 2013 15:51:53 +0100
Message-ID: <20131024145153.GA23431@kroah.com>
References: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
 <1382585497-6787-2-git-send-email-Larry.Finger@lwfinger.net>
 <20131024101001.GD5871@mwanda>
 <526932DD.2080602@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:38090 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755644Ab3JXOuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 10:50:18 -0400
Content-Disposition: inline
In-Reply-To: <526932DD.2080602@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 09:46:53AM -0500, Larry Finger wrote:
> On 10/24/2013 05:10 AM, Dan Carpenter wrote:
> > I have looked at how this is called from ioctl_private_call() and it
> > seems like these are actual user pointers and the code is buggy.  The
> > patch silences the warnings instead of fixing the bugs.
> 
> Thanks for the review.
> 
> Greg - please drop this one and take only 2-5. Do you want a resubmission?

I can just drop it.  I'm way behind on patches due to the kernel summit
and LinuxCon, so it will be a week or so before I can catch up, sorry.

greg k-h
