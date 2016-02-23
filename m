From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Tue, 23 Feb 2016 11:47:14 +0100
Message-ID: <20160223104714.GD26042@torres.zugschlus.de>
References: <20151212195830.GA18286@torres.zugschlus.de>
 <56796902.8080703@stressinduktion.org>
 <20151222212843.GE4424@torres.zugschlus.de>
 <5679C58C.2090308@stressinduktion.org>
 <20160222150443.GV26042@torres.zugschlus.de>
 <56CB2564.9030003@stressinduktion.org>
 <20160222154758.GW26042@torres.zugschlus.de>
 <56CB342D.9010100@stressinduktion.org>
 <20160222192039.GC26042@torres.zugschlus.de>
 <56CC2060.1050904@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:51994 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbcBWKrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 05:47:16 -0500
Content-Disposition: inline
In-Reply-To: <56CC2060.1050904@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 10:03:28AM +0100, Hannes Frederic Sowa wrote:
> Thanks for letting me know. Hopefully this also fixes
> https://bugzilla.kernel.org/show_bug.cgi?id=110721.

As far as I have understood the systemd release logs, the code
handling IPv6 RAs was added in systemd 229, which was released on
February 11. So, #110721, filed in January, seems to be "safe" from
this issue unless a development snapshot of systemd was used here.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
