From: raj ravi <mekaviraj@gmail.com>
Subject: GSO / TSO offload dependency
Date: Sun, 28 Feb 2010 22:30:24 +0530
Message-ID: <de0a9dcb1002280900k728b241fyd72112defc0336ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50233 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964812Ab0B1RAZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 12:00:25 -0500
Received: by vws10 with SMTP id 10so76709vws.19
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 09:00:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I m currently working on TSO feature in Linux network driver.

Please correct my understanding.

GSO - Generic segmentation offload - does not require any hardware supp=
ort.

TSO - TCP segmentation offload=A0 - does require hardward support


Does TSO needs GSO to be turned on?=A0 OR in other words,=A0 can I have
GSO disabled and TSO Enabled ?
I beleive the code is tied between both offload...but not sure about
the above possibility... please clarify.


Just before handing over the packets to the Network driver,
segmentation is carried out a call to dev_gso_segment ( ) function.
Given GSO is enabled, It will take care about creating TCP and other
protocol=A0 segments=A0 too,=A0 even if TSO is disabled.. ..correct ?

If hardware supports TSO, and=A0 If TSO and GSO are both enabled, ...
what will happen to segmentation assembly by means of GSO ...
GSO will not do any segmentatoin assembly for TCP alone and will do
for other protocols ??=A0 bit confused here? Please clarify.

Thx!
Kavi
