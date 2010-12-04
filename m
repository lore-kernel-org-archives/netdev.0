From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 17:56:09 +0100
Message-ID: <20101204165609.GB1981@del.dom.local>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
 <4CFA3F01.20109@gmail.com>
 <1291472889.2159.18.camel@mojatatu>
 <1291474127.2159.35.camel@mojatatu>
 <20101204154007.GA1981@del.dom.local>
 <1291478881.2159.70.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45461 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab0LDQ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 11:56:16 -0500
Received: by wwa36 with SMTP id 36so11255785wwa.1
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 08:56:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1291478881.2159.70.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 04, 2010 at 11:08:01AM -0500, jamal wrote:
> On Sat, 2010-12-04 at 16:40 +0100, Jarek Poplawski wrote:
> 
> > Hmm... But we didn't care until now... ;-) 
> 
> Well, if Changli didnt post - there would be no discussion ;->
> The message was lost in the translation somewhere; events such as
> patches sometimes serve as good reminders.
> 
> > Btw. is it really very
> > probable (and worth bothering) that this current error of NULL dev
> > get fixed before we purge this tq queue with deferral one by one?
> 
> Indeed - this is working against something buggy. But it has happened
> often in the past. And the likelihood of there being a few bad ones
> in the train of packets when this occurs is high. But there are many
> packets there that wont suffer this sympton - so the only fair scheme is
> to check all. Note: a BUG() seems unreasonable and the deferring  serves
> as a throttling scheme.
> What do you have in mind?

I'm simply not convinced this kind of (fast) throttling can properly
fix any of the problems (what about other flows in the queue), while
Changli's patch makes this tasklet simpler and a bit faster.

Cheers,
Jarek P.
