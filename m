From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Sun, 1 Jun 2008 19:48:39 +0200
Message-ID: <200806011948.39770.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <20080526142209.GA20164@gerrit.erg.abdn.ac.uk> <200805262340.53355.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2548 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbYFARs6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 13:48:58 -0400
In-Reply-To: <200805262340.53355.tomasz@grobelny.oswiecenia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Monday 26 of May 2008, napisa=B3e=B6:
> Dnia Monday 26 of May 2008, Gerrit Renker napisa=B3:
> > | As for information we can get from kernel wrt dccp we have at lea=
st:
> > | 1. fixed information that depends only on kernel version. For exa=
mple
> > | list of ccids, list of available qpolicies, list of parameters fo=
r
> > | given qpolicy, etc. These are system wide and don't need referenc=
e to
> > | socket. These could even be exposed by read-only entries in /sys =
or
> > | /proc.
> >
> > That is a good point - I think Arnaldo had a similar idea once for
> > implenting system-wide policies regarding which CCIDs are supported=
=2E
> > Something like net.ipv4.tcp_available_congestion_control.
>
> Ok, we may go this way. I'll try to write a patch in a few days (quit=
e busy
> now).
>
Now that I had a closer look at implementing this functionality I have =
a few=20
questions:
1. Where should information about available qpolicies and their paramet=
rs be=20
exported? Would /proc/net/dccp/qpolicies/ be a good choice?
2. I guess we should have at least one file per qpolicy with parameters=
 listed=20
inside. Like that:
/proc/.../qpolicies/simple: <empty>
/proc/.../qpolicies/prio: 1 (DCCP_SCM_PRIORITY) 2 (DCCP_SCM_TIMEOUT)
But we could also have qpolicy represented by directory and parameters =
by=20
files:
/proc/.../qpolicies/simple/
/proc/.../qpolicies/prio/
/proc/.../qpolicies/prio/priority: <empty>
/proc/.../qpolicies/prio/timeout: <empty>
Which layout do you find better?
--=20
Regards,
Tomasz Grobelny
