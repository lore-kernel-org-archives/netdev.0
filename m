From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: problems with e1000 and flow control
Date: Mon, 25 Feb 2008 20:15:49 +0100
Message-ID: <200802252015.49862.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:55844 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755320AbYBYTjO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 14:39:14 -0500
Received: from mailhub.studentenwerk.mhn.de (mail.studentenwerk.mhn.de [10.148.7.34])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 7A7C358002
	for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 20:15:50 +0100 (CET)
Received: from mist.as.studentenwerk.mhn.de (mist.as.studentenwerk.mhn.de [10.148.0.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailhub.studentenwerk.mhn.de (Postfix) with ESMTP id 71222DB991
	for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 20:15:50 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

it seems that e1000 enables flow-control (rx pause frames) even if the =
switch=20
does not advertise flow control. This seems to get a problem as (at lea=
st=20
some) switches then forward pause frames directed to the card from othe=
r=20
hosts. We think there are hosts which indeed do this in the lans of our=
=20
student halls.

I think flow control should be completely disabled by default if the sw=
itch=20
does not advertise it. It still can be forced with ethtool.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

