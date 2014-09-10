From: =?ISO-8859-15?Q?Daniel_Gl=F6ckner?= <dg@emlix.com>
Subject: PTP_PEROUT_REQUEST and clock stepping
Date: Wed, 10 Sep 2014 18:16:37 +0200
Message-ID: <54107965.6040007@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([88.198.240.195]:58094 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbaIJQ0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 12:26:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I was wondering how periodic output is supposed to behave if the clock
is stepped from a time after ptp_perout_request.start to a time before
ptp_perout_request.start. Should the periodic output stop until .start
is reached again or should it ignore .start once periodic output has
started?

Best regards,

  Daniel


--=20
Dipl.-Math. Daniel Gl=F6ckner, emlix GmbH, http://www.emlix.com
=46on +49 551 30664-0, Fax +49 551 30664-11,
Bertha-von-Suttner-Stra=DFe 9, 37085 G=F6ttingen, Germany
Sitz der Gesellschaft: G=F6ttingen, Amtsgericht G=F6ttingen HR B 3160
Gesch=E4ftsf=FChrer: Dr. Uwe Kracke, Ust-IdNr.: DE 205 198 055

emlix - your embedded linux partner
