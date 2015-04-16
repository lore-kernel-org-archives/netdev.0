From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Bluetooth: Pre-initialize variables in read_local_oob_ext_data_complete()
Date: Thu, 16 Apr 2015 13:34:54 -0700
Message-ID: <A962A040-4EB5-4AE6-A790-A8767185172B@holtmann.org>
References: <1429212265-26750-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35243 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbbDPUfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 16:35:02 -0400
In-Reply-To: <1429212265-26750-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

> net/bluetooth/mgmt.c: In function =E2=80=98read_local_oob_ext_data_co=
mplete=E2=80=99:
> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r256=E2=80=99 may be use=
d uninitialized in this function
> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h256=E2=80=99 may be use=
d uninitialized in this function
> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r192=E2=80=99 may be use=
d uninitialized in this function
> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h192=E2=80=99 may be use=
d uninitialized in this function
>=20
> While these are false positives, the code can be shortened by
> pre-initializing the hash table pointers and eir_len. This has the si=
de
> effect of killing the compiler warnings.

can you be a bit specific on which compiler version is this. I fixed on=
e occurrence that seemed valid. However in this case the compiler seems=
 to be just plain stupid. On a gcc 4.9, I am not seeing these for examp=
le.

Regards

Marcel
