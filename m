From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Fri, 20 Jun 2008 23:03:37 +0200
Message-ID: <200806202303.37924.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806182246.15433.tomasz@grobelny.oswiecenia.net> <20080619070501.GA7268@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2577 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbYFTVED convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 17:04:03 -0400
In-Reply-To: <20080619070501.GA7268@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Thursday 19 of June 2008, Gerrit Renker napisa=B3:
> But such a bottom-up approach would not necessarily make sense, since
> likely the policy will do a bit more work than just reacting to the
> parameters it uses, which leads to the next point.
>
Agreed.

> | Could be nice, but what happens if we have two policies with the sa=
me set
> | of supported parameters? How do we differentiate them? In the above=
: how
> | do we diffrentiate between simple policy (which doesn't have any
> | parameters ever) and prio policy with no parameters (just because w=
e
> | don't need to provide any for one particular case)?
>
> We could still encode the parameters in the policy ID, by splitting t=
he
> bitmask, e.g. the low 24 bits to encode parameters, and the high 8 bi=
ts
> to encode the policies using the same combination of parameters.
>
Yes, technically we could do it this way. Encoding accepted parameters =
in=20
policy ID would provide applications with means to check whether certai=
n=20
parameters are supported. But should we mix two IMO distinct concepts (=
policy=20
behaviour and accepted parameters) in one bitfield? I'd rather have the=
m=20
separated.

Keeping policy IDs as they are and using a bitfield for just parameters=
 could=20
be a nice idea. It would certainly  simplify checking which parameters =
are=20
supported - just a simple & and =3D=3D would suffice.
--=20
Regards,
Tomasz Grobelny
