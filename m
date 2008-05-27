From: Patrick McHardy <kaber@trash.net>
Subject: GVRP
Date: Tue, 27 May 2008 18:10:51 +0200
Message-ID: <483C328B.7040007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57714 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757429AbYE0QKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 12:10:54 -0400
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id 15116948D7
	for <netdev@vger.kernel.org>; Tue, 27 May 2008 18:10:53 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've written an applicant-only GVRP implementation for the kernel
some time ago (for those not familiar: it dynamically registers
VLANs with switches. Applicant-only means its only the "client-side")
and I'm wondering whether I should merge it. It should be quite
easy to move it to userspace, OTOH I think it would be nice to
have the client-side support for this without having to install
additional daemons. But since this is not a really strong argument,
I'd like to hear if anyone has an opinion about this.

The GVRP implementation sits on top of an GARP implementation,
which could also support GMRP for multicast address registrations.

I'm not including the patch yet because it would need to be
split up and needs some minor cleanups, just for orientation, the
GARP implementation is about 600 lines of simple code, the GVRP
implementation something like 60 lines of even simpler code.

Opinions welcome.
