From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sun, 25 Sep 2011 11:16:06 +0200
Message-ID: <20110925091606.GE32712@torres.zugschlus.de>
References: <20110902172247.396753508@vyatta.com>
 <4E614CF7.7030700@gmail.com>
 <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
 <4E6272BC.4020707@gmail.com>
 <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
 <4E632A2E.5040805@gmail.com>
 <20110904093634.685d7c56@nehalam.ftrdhcpuser.net>
 <4E65046E.1020005@gmail.com>
 <20110905105735.1b912715@nehalam.ftrdhcpuser.net>
 <4E65C31F.1010809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:33788 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab1IYJQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 05:16:08 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1R7kog-0000Em-LV
	for netdev@vger.kernel.org; Sun, 25 Sep 2011 11:16:06 +0200
Content-Disposition: inline
In-Reply-To: <4E65C31F.1010809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2011 at 08:52:15AM +0200, Nicolas de Peslo=C3=BCan wrot=
e:
> I really support the idea to keep the current behavior (assert
> carrier on br0 when at least one port have carrier) and to fix the
> applications to wait for the IPv6 address to be checked (DAD)
> instead of dying on bind() failure.

A really brilliant idea. Break things and then expect hundreds of apps
or millions of installations to adapt.

Greetings
Marc

--=20
-----------------------------------------------------------------------=
------
Marc Haber         | "I don't trust Computers. They | Mailadresse im He=
ader
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 7273=
9834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 232=
3190
