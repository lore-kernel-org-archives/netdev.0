From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: net 00/05: routing based send-to-self implementation
Date: Mon, 30 Nov 2009 11:32:30 -0800
Message-ID: <m1r5rf4xm9.fsf@fess.ebiederm.org>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45403 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbZK3Tc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 14:32:29 -0500
In-Reply-To: <20091130175529.7555.10132.sendpatchset@x2.localnet> (Patrick McHardy's message of "Mon\, 30 Nov 2009 18\:55\:30 +0100 \(MET\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> These patches are yet another attempt at adding "send-to-self" functionality,
> allowing to send packets between two local interfaces over the wire. Unlike
> the approaches I've seen so far, this one is purely routing based.
> Especially the oif classification should also be useful for different setups.

Why not put each physical interface in a different network namespace?
That should work with no changes today.

Eric
