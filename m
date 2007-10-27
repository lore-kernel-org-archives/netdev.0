From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Files, sockets, and closing
Date: Sat, 27 Oct 2007 20:03:34 +0200
Message-ID: <p73wst8o2o9.fsf@bingen.suse.de>
References: <20071026140319.5bcc8ac0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@ftp.linux.org.uk>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:57710 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbXJ0SDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Oct 2007 14:03:37 -0400
In-Reply-To: <20071026140319.5bcc8ac0@freepuppy.rosehill> (Stephen Hemminger's message of "Fri\, 26 Oct 2007 14\:03\:19 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This particular problem has come up many times over the years. So far
the standard strategy has been to ignore it. It's doubtful that the
complexity needed for a fix is worth it.

Workaround at user space level: call shutdown() first instead of close()

-Andi
