From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Fri, 6 Jun 2008 00:19:17 +0300
Message-ID: <200806060019.17589.maximlevitsky@gmail.com>
References: <200806011515.14103.maximlevitsky@gmail.com> <20080605071339.GA11562@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:55810 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbYFEVTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 17:19:25 -0400
Received: by ug-out-1314.google.com with SMTP id h2so604019ugf.16
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 14:19:22 -0700 (PDT)
In-Reply-To: <20080605071339.GA11562@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 5 June 2008 10:13:40 Evgeniy Polyakov wrote:
> On Sun, Jun 01, 2008 at 03:15:14PM +0300, Maxim Levitsky (maximlevitsky@gmail.com) wrote:
> > Is there a way to close all TCP sockets before/after suspend to ram?
> 
> You can do that with frevoke patchset (not in mainline though iirc),
> which allows you to close any file descriptor, which you can find via
> /proc/$pid/fd
> 

Seems like a great idea.
Do you know the status of this patchset, when to expect it to be
in included in mainline?


Thanks a lot,
	Best regards,
		Maxim Levitsky
