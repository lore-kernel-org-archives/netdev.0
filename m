From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 0/2] cxgb4vf: small fixes to new driver
Date: Wed, 30 Jun 2010 14:13:42 -0700
Message-ID: <201006301413.42716.leedom@chelsio.com>
References: <201006291552.14816.leedom@chelsio.com> <20100630.140513.171484395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16855 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944Ab0F3VOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:14:36 -0400
In-Reply-To: <20100630.140513.171484395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>
| Date: Wednesday, June 30, 2010 02:05 pm
| 
| I've applied both patches but you really need to fix up how you
| submit these changes.

  Thanks David.  I won't submit any more patches till I get my local git patch 
experts to vet the results.  You shouldn't be asked to do such mechanical patch 
fixups.  I appreciate your time in describing this.  Thanks!

Hoping not to be a Patch Bozo in future submissions,
Casey

P.S. Is the below in a FAQ and/or Wiki somewhere?  if not, I think it would make 
a valuable addition.  (And if it already is in a FAQ/Wiki then I'm even more of 
a Patch Bozo ...)

| 1) Your Subject: line becomes the commit message header.
| 
|    It should be a single statement, prefixed by "xxx: "
|    where "xxx" is the subsystem or driver you are making
|    changes to.  Here it would be "cxgb4vf: "
| 
|    It should not bleed into the rest of commit message body, like
|    your's did.
| 
| 2) You should not include all of the commit crap from GIT in the body
|    of your email.  I just have to edit all of that junk out before I
|    apply your patch.
| 
| A perfect email patch submission looks like this (my comments are in
| {} braces):
| 
| From: Me <me@wherever.com>
| Subject: [PATCH N/M] subsystem: Make whatever do whatever.
| 
| { Next line is optional, it goes into your email body and is used
|   when the patch author is someone other than the person sending
|   the email }
| 
| From: Real Author <cooldude@wherever.com>
| 
| This explains what this commit message is doing.
| 
| It gives code path traces, pretty ascii-art diagrams, and cross
| references when doing so helps other people understand the change.
| 
| Signed-off-by: Real Author <cooldude@wherever.com>
| Signed-off-by: Me <me@wherever.com>
| 
| { "---" marks the end of the commit message text, afterwards you
|    can add whatever auxiliary information you want people to know about
|    the patch, but for whatever reason it'snt appropriate for the
|    commit message. }
| 
| ---
| 
| This is some extra information I want the list to see when I post
| this patch.
| 
| { And finally the full patch comes next. }
| 
| Ok?  All of the GIT tools know exactly how to pick apart the above
| formatted patch and apply it to the tree with the author, etc. all
| set properly.
| 
| And this is the format output by "git send-email" so you can use it
| to help construct proper patch postings even if you don't want to
| use "git send-email" to send the email directly.
