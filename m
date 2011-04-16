From: =?ISO-8859-2?Q?Fejes_J=F3zsef?= <fejes@joco.name>
Subject: r8169 misleading firmware error messages
Date: Sat, 16 Apr 2011 10:27:01 +0200
Message-ID: <4DA952D5.7030805@joco.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail00a.mail.t-online.hu ([84.2.40.5]:26017 "EHLO
	mail00a.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854Ab1DPIg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 04:36:26 -0400
Received: from [192.168.55.109] (54032ADF.catv.pool.telekom.hu [84.3.42.223])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail00a.mail.t-online.hu (Postfix) with ESMTPSA id 8642125637A
	for <netdev@vger.kernel.org>; Sat, 16 Apr 2011 10:26:41 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm using Linux 2.6.38.3 with a Realtek 8169 card, ID: 10ec:8168=20
(integrated into an Intel D945GSEJT mobo). It never needed any firmware=
=20
files, and when I was using 2.6.37, it never complained about it either=
=2E=20
Now it does complain (but it still works perfectly):

r8169 0000:01:00.0: eth0: unable to apply firmware patch

Also when I do initramfs stuff:

W: Possible missing firmware /lib/firmware/rtl_nic/rtl8168d-2.fw for=20
module r8169
W: Possible missing firmware /lib/firmware/rtl_nic/rtl8168d-1.fw for=20
module r8169

So then I installed the rtl_nic firmware files, and the error messages=20
were gone.

How do I know if it actually tries to load the firmware at all? I see=20
there's a condition, if an rtl_readphy returns a wrong value, it doesn'=
t=20
even try to load the firmware and just prints the message. Although thi=
s=20
wouldn't explain why the error message disappeared when the files were=20
there.

Clearly, my device works without these firmware files. If my device=20
works better with them, or if there are other similar devices which=20
require it, I think there should be a configuration option to disable=20
this firmware stuff and its benefits altogether so that it doesn't even=
=20
report that it needs it.

Best regards,

--=20
=46ejes J=F3zsef
http://joco.name
