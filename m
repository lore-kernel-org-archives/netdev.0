From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 19:07:46 +0100
Message-ID: <20070324180746.GA3119@florz.florz.dyndns.org>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <20070324002242.GA26017@florz.florz.dyndns.org> <460561E3.9020502@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.160.141] ([77.10.160.141]:2379 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbXCXSHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 14:07:50 -0400
Content-Disposition: inline
In-Reply-To: <460561E3.9020502@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Florian Zumbiehl wrote:
> >Hi,
> >
> >>+ * 251003 :	Copied from pppoe.c version 0.6.9.
> >
> >you might want to have a look at the patches to the PPPoE code that were
> >posted to netdev recently, as some of them seem to apply to code that's
> >left over from pppoe.c.
> 
> Do you mean this change?
> 
>  * 070228 : Fix to allow multiple sessions with same remote MAC and same
>  *	    session id by including the local device ifindex in the
>  *	    tuple identifying a session. This also ensures packets can't
>  *          be injected into a session from interfaces other than the
>  *          one	specified by userspace. Florian Zumbiehl 
>  <florz@gmx.de>
> 
> The pppoe session hash table isn't used in the pppol2tp code so the 
> above change doesn't affect pppol2tp. I rechecked the latest pppoe.c and 
> I don't see other changes that haven't already been incorporated in 
> pppol2tp. Which specific code in pppol2tp do you think needs to be updated?

I meant those that haven't been committed yet (AFAIK):

http://www.spinics.net/lists/netdev/msg26926.html
http://www.spinics.net/lists/netdev/msg26927.html
http://www.spinics.net/lists/netdev/msg26928.html
http://www.spinics.net/lists/netdev/msg26751.html
http://www.spinics.net/lists/netdev/msg26752.html
http://www.spinics.net/lists/netdev/msg26753.html
http://www.spinics.net/lists/netdev/msg26754.html
http://www.spinics.net/lists/netdev/msg26787.html

(Plus the respective followup postings, of course.)

Some probably don't apply. I didn't have a very detailed look at your
code, but some certainly do apply.

Florian
