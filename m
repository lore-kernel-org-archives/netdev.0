From: =?iso-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Subject: Re: [PATCH] net/sched: add ACT_CSUM action to update packets
 checksums
Date: Tue, 17 Aug 2010 01:02:17 +0200
Message-ID: <20100816230217.GA24125@n7mm.org>
References: <20100816211542.GA21083@n7mm.org>
 <1281996019.5765.6.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from solo.fdn.fr ([80.67.169.19]:53115 "EHLO solo.fdn.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756103Ab0HPWpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 18:45:00 -0400
Content-Disposition: inline
In-Reply-To: <1281996019.5765.6.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Excellent work! Ive always wanted to do this albeit slightly
> differently.
Thanks!

> I think it would be nice to factor a lot of the code repeated
> everywhere into some boilerplate function that gets invoked by all;
> users.
You're rigth. I will correct that, maybe using a macro which is
specialised to get the protocol structure ...
However, this macro could call a 'goto' instruction. Is it really a goo=
d
idea? Tell me. Are you sure a function is appropriate?

Regards,
Gr=E9goire
