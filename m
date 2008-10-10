From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Fri, 10 Oct 2008 09:04:26 +0000
Message-ID: <20081010090426.GA6054@ff.dom.local>
References: <20081010075640.GA5204@ff.dom.local> <48EF17EA.5020306@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:14437 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757771AbYJJJEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 05:04:32 -0400
Received: by ey-out-2122.google.com with SMTP id 6so176362eyi.37
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 02:04:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EF17EA.5020306@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2008 at 12:52:58PM +0400, Badalian Vyacheslav wrote:
> Oh... sorry. I Wrong you understand... i patch 2.6.27 with this patch
> and will test it...

No, you understood it right. But it seems 2.6.27 fix doesn't work for
you. So, yes, try this patch with 2.6.26 or 2.6.27.

Jarek P.


> 
> >> Please look to if you have time:
> >> http://bugzilla.kernel.org/show_bug.cgi?id=11718
> >>
> >> We have deadlocks at few PC one times in week.
> >> I can test any patches to detect and fix problem.
> >> Now i test 2.6.27-rc kernel at one PC.
> >>     
> >
> > A similar bug was reported by Denys Fedoryshchenko but it wasn't fully
> > diagnosed. Anyway it looks like hardware dependent. The patch below
> > can sometimes help. 2.6.27 may have this fixed too (some other way).
> >
> > Jarek P.
> 
