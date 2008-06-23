From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with
	software LRO
Date: Mon, 23 Jun 2008 22:48:40 +0200
Message-ID: <20080623204840.GB2462@ami.dom.local>
References: <485B4ADE.8070102@domat.com.pl> <200806202344.12771.opurdila@ixiacom.com> <20080622210747.GA17472@ami.dom.local> <200806231250.31087.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:31583 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488AbYFWUsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 16:48:54 -0400
Received: by wx-out-0506.google.com with SMTP id h29so822941wxd.4
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 13:48:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200806231250.31087.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 12:50:30PM +0300, Octavian Purdila wrote:
> On Monday 23 June 2008, Jarek Poplawski wrote:
...
> > But, I think it's better to separate the change of functionality (a
> > recursive processing of frag_list) to another patch (if there is a
> > practical reason for this).
> >
> 
> Yes, it makes sense, I'll remove the recursion from this patch. 
> 
> About the recursion: don't know if it makes a difference from a functional 
> perspective (I don't think that we can have frag_lists in frag_lists), but 
> I've noticed that skb_copy_bits does recurse. Any idea why?

I meant it's potentially the change of functionality in this place.
Probably this recursion is intended for 1 level only, and is natural
in this place. But, since this place didn't use this, it should be
safer to separate this change to another patch (of course, consistency
with skb_copy_bits could be a good argument).

Jarek P.
