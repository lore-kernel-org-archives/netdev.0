From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: ixgbe: net-next build breakage
Date: Thu, 14 Oct 2010 21:33:33 -0700
Message-ID: <AANLkTin8he7aexkL+mpbXen_odu4upo5buJWd7iGW-He@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, stephen.s.ko@intel.com,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:47766 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856Ab0JOEde convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 00:33:34 -0400
Received: by iwn35 with SMTP id 35so437705iwn.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 21:33:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f32f837b75233588cd4f8542214a30915ab7847b
Author: Emil Tantilov <emil.s.tantilov@intel.com>
Date:   Tue Oct 12 22:20:34 2010 +0000

    ixgbe: remove unused functions


Breaks the build:
drivers/net/ixgbe/ixgbe_main.c: In function =E2=80=98ixgbe_configure_dc=
b=E2=80=99:
drivers/net/ixgbe/ixgbe_main.c:3377: error: implicit declaration of
function =E2=80=98ixgbe_dcb_check_config=E2=80=99
make[2]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1
make[1]: *** [drivers/net/ixgbe] Error 2
make: *** [drivers/net/] Error 2

As ixgbe_dcb_check_config no longer exists in the tree.

Cheers,

Harvey
