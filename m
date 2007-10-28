From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [linux-pm] QUESTION: How to fix race between .suspend routine and watchdog timer
Date: Sun, 28 Oct 2007 21:19:05 +0200
Message-ID: <200710282119.05266.maximlevitsky@gmail.com>
References: <Pine.LNX.4.44L0.0710271820240.2321-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:61850 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbXJ1TTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 15:19:15 -0400
Received: by ug-out-1314.google.com with SMTP id z38so903162ugc
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2007 12:19:13 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.44L0.0710271820240.2321-100000@netrider.rowland.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 28 October 2007 00:24:10 Alan Stern wrote:
> On Sat, 27 Oct 2007, Maxim Levitsky wrote:
> 
> > > Use del_timer_sync().  It guarantees that when it returns, the timer 
> > > will be stopped and the timer routine will no longer be running on any 
> > > CPU.
> > > 
> > Even if the timer re-enables itself, are you sure?
> 
> Last time I looked at the source code, that's what it did.  I'll look
> again...  Yep, it still does.  It checks to see if the timer routine is
> currently running; if so then it waits a little while and tries again.
> 
> Alan Stern
> 
> 

Thanks, a lot,
	Best regards,
		Maxim Levitsky
