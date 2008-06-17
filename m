From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Tue, 17 Jun 2008 22:28:05 +0200
Message-ID: <200806172228.06801.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806150158.28488.tomasz@grobelny.oswiecenia.net> <20080617111638.GA14409@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:1190 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754848AbYFQU2Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 16:28:25 -0400
In-Reply-To: <20080617111638.GA14409@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Tuesday 17 of June 2008, Gerrit Renker napisa=B3:
> | In other words the basic question is: do we want to add new paramet=
ers to
> | existing qpolicies (then we need parameter discovery) or we don't w=
ant
> | new parameters (then we don't need information about parameters ava=
ilable
> | at runtime).
> |
> | Having defined the alternatives it's time to decide which is better=
=2E I,
> | of course, claim that mine (which is adding new parameters to exist=
ing
> | qpolicies). That's simply because I think that providing both
> | DCCP_SCM_TIMEOUT and DCCP_SCM_PRIORITY parameters may be useful. An=
d I
> | don't see an obvoius way of achieving that goal with "new policy fo=
r new
> | parameter" approach.
>
> I agree that providing both parameters may be useful, but don't see t=
his
> as a place of contradiction.
>
> In the kernel I think it is best to make it type-safe, i.e. no new
> parameters to already-defined policies. But I can't see how this woul=
d
> restrict the use.
> (...)
>
So we would need new policy for each new parameter, right? I somehow do=
n't=20
like it but it should work. You are right that this way runtime paramet=
er=20
discovery is not necessary. BTW, we will have a bit of a problem with n=
aming=20
qpolicies ;-)

> | > With a manpage I mean to document
> |
> | Is there any "man dccp"?
>
> Not yet. If you or someone else can find time to contribute towards a=
 DCCP
> manpage, that would be just great. The best available information so =
far is
> on the OSDL pages for DCCP and Documentation/networking/dccp.txt.
>
But it's not in kernel sources? Then probably a new page would not be a=
ccepted=20
as it would describe an experimental API. The above mentioned dccp.txt =
is=20
probably the best place for now.

> I think there is a special maintainer for the kernel manpages, who co=
uld
> be emailed with a basic manpage. But ther ere is a similar problem - =
if the
> API changes frequently, then this requires to update the manpage
> accordingly.
>
I guess these would mostly be API additions, without any incompatible c=
hanges.

> As alternatives to documentation, there are for example providing
>  *running source code,
I will for sure be working on some apps to demonstrate how the new inte=
rface=20
can be used. But first I need to create a simple server/client transmit=
ting=20
G.726 encoded voice over UDP/RTP (any hints on that?)...

>  * web pages or
Is there any official, publicly editable DCCP wiki? I'd rather not crea=
te yet=20
another page...
--=20
Regards,
Tomasz Grobelny
