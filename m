From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 2/2] [RFT] [DCCP]: Policy-based packet dequeueing
Date: Mon, 12 May 2008 10:33:54 +0200
Message-ID: <200805121033.55262.tomasz@grobelny.oswiecenia.net>
References: <bug_fix_and_qpolicy_interface> <1210578484-12571-2-git-send-email-gerrit@erg.abdn.ac.uk> <1210578484-12571-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4040 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbYELIeS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 04:34:18 -0400
In-Reply-To: <1210578484-12571-3-git-send-email-gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Monday 12 of May 2008, napisa=B3e=B6:
> From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
>
> This patch adds a generic infrastructure for policy-based dequeueing =
of
> TX packets and provides two policies:
>  * a simple FIFO policy (which is the default) and
>  * a priority based policy (set via socket options).
> Both policies honour the tx_qlen sysctl for the maximum size of the w=
rite
> queue (can be overridden via socket options).
>
> The priority policy uses skb->priority internally to assign an u32 pr=
iority
> identifier, using the same ranking as SO_PRIORITY. The skb->priority =
field
> is set to 0 when the packet leaves DCCP. The priority is supplied as
> ancillary data using cmsg(3), the patch also provides the requisite p=
arsing
> routines.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>

I hope that's how you sign off patches (I'm doing it for the first time=
).
--=20
Regards,
Tomasz Grobelny
