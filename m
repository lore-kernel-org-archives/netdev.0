From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: [net-next-2.6] Latest GIT pulled into linux-next
Date: Sat, 12 Mar 2011 13:26:54 +0100
Message-ID: <AANLkTi=hna0mq5QTahDP8bHCq5_6ezs7PFeimpLuUe7S@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50719 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab1CLM0z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 07:26:55 -0500
Received: by qwk3 with SMTP id 3so363223qwk.19
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 04:26:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I pulled net-next-2.6 (last commit
70d279a7e2a6e308530822ba2bf4134cc0f5c091 "e1000e: bump version
number") into linux-next (next-20110311).

Unfortunately, I see this breakage:

[ build.log ]
=2E..
In file included from
/home/sd/src/linux-2.6/linux-2.6.38-rc8/debian/build/source_i386_none/d=
rivers/block/cciss.c:351:0:
/home/sd/src/linux-2.6/linux-2.6.38-rc8/debian/build/source_i386_none/d=
rivers/block/cciss_scsi.c:
In function =E2=80=98scsi_cmd_stack_setup=E2=80=99:
/home/sd/src/linux-2.6/linux-2.6.38-rc8/debian/build/source_i386_none/d=
rivers/block/cciss_scsi.c:229:48:
error: =E2=80=98struct cciss_scsi_cmd_stack_t=E2=80=99 has no member na=
med =E2=80=98nelems=E2=80=99
/home/sd/src/linux-2.6/linux-2.6.38-rc8/debian/build/source_i386_none/d=
rivers/block/cciss_scsi.c:
In function =E2=80=98scsi_cmd_stack_free=E2=80=99:
/home/sd/src/linux-2.6/linux-2.6.38-rc8/debian/build/source_i386_none/d=
rivers/block/cciss_scsi.c:266:12:
error: incompatible types when assigning to type =E2=80=98struct
cciss_scsi_cmd_stack_elem_t *[34]=E2=80=99 from type =E2=80=98void *=E2=
=80=99

Just FYI.

Regards,
- Sedat -
