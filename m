From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: Kconfig warnings on latest GIT
Date: Tue, 8 May 2007 14:31:27 -0500
Message-ID: <20070508143127.38fafa3c.kim.phillips@freescale.com>
References: <200705080004.14570.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Timur Tabi <timur@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?ISO-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:35098 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967821AbXEHTb5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 15:31:57 -0400
In-Reply-To: <200705080004.14570.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007 00:04:14 +0300
Ismail D=F6nmez <ismail@pardus.org.tr> wrote:

>=20
> drivers/net/Kconfig:2279:warning: 'select' used by config symbol 'UCC=
_GETH'=20
> refers to undefined symbol 'UCC_FAST'

looks like this introduces the error:

commit 7d776cb596994219584257eb5956b87628e5deaf
Author: Timur Tabi <timur@freescale.com>
Date:   Mon Mar 12 15:40:27 2007 -0500

    [POWERPC] QE: automatically select QE options

    Change the Kconfig files so that the Freescale QE options are autom=
atically
    selected if a QE device is selected.  Previously, you'd need to man=
ually
    select UCC_FAST if you want any "fast" UCC devices, such as Gigabit=
 Ethernet
    Now, the QE Gigabit Ethernet option is always available if the devi=
ce has a
    QE, and UCC_FAST is automatically enabled.  A side-effect is that t=
he
    "QE Options" menu no longer exists.

    Signed-off-by: Timur Tabi <timur@freescale.com>
    Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

cc:ing authors, fti.

Kim
