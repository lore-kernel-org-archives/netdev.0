From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net,stable 0/7] qmi_wwan: adding a few new devices
Date: Sat, 26 Apr 2014 19:18:19 +0200
Message-ID: <87lhusc8mc.fsf@nemi.mork.no>
References: <1398445234-26620-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51435 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbaDZRSY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 13:18:24 -0400
In-Reply-To: <1398445234-26620-1-git-send-email-bjorn@mork.no>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Fri, 25 Apr 2014 19:00:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> These new device ID patches should also go to all maintained stable k=
ernels
> where they apply. I believe that should be stable-3.10 and newer.

At least if the following mainline commits are cherry-picked first,
bringing the device id list up-to-date with v3.14:


=46or stable-3.10.y:

5a008ffa73b4 net: qmi_wwan: fixup Sierra Wireless MC8305 entry
aa3aba1cbcbe net: qmi_wwan: add Option GTM681W
d0b5e516298f net: qmi_wwan: add TP-LINK MA260
d8eb8f9963a5 qmi_wwan: add ONDA MT689DC device ID (fwd)
905468fa4d54 net: qmi_wwan: add Telit LE920 newer firmware support
2d77f343343c net: qmi_wwan: fix Cinterion PLXX product ID
  [requires context fixup]
ce97fef42353 net: qmi_wwan: Olivetti Olicard 200 support
  [requires context fixup]
7653aabfbdc7 net: qmi_wwan: add ZTE MF667
9b2b6a2d669c net: qmi_wwan: add support for Cinterion PXS8 and PHS8


=46or stable-3.12.y:

905468fa4d54 net: qmi_wwan: add Telit LE920 newer firmware support
  [requires context fixup]
7653aabfbdc7 net: qmi_wwan: add ZTE MF667
9b2b6a2d669c net: qmi_wwan: add support for Cinterion PXS8 and PHS8


Let me know if you want me to post these in fixed up state, as patch
series or in some other format.


Bj=C3=B8rn
