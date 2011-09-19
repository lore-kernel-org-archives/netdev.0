From: Arnaud Lacombe <lacombar@gmail.com>
Subject: Re: MSI-X vector count on 82754L
Date: Mon, 19 Sep 2011 01:34:27 -0400
Message-ID: <CACqU3MUfQn_r2oJ+ptuzYhkkUoucfL_NTMnHoCa0+TouP0s0kA@mail.gmail.com>
References: <CACqU3MVZ6GT7hNKsnWq-otxsX4TDtTi8qYPG=4gYn=cBF7-tJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jack Vogel <jack.vogel@intel.com>
To: Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57605 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab1ISFe2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 01:34:28 -0400
Received: by wwf22 with SMTP id 22so7473925wwf.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 22:34:27 -0700 (PDT)
In-Reply-To: <CACqU3MVZ6GT7hNKsnWq-otxsX4TDtTi8qYPG=4gYn=cBF7-tJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[fixing address of the netdev@ list, sorry - A.]

On Mon, Sep 19, 2011 at 1:31 AM, Arnaud Lacombe <lacombar@gmail.com> wr=
ote:
> Hi folks,
>
> In:
>
> commit 4662e82b2cb41c60826e50474dd86dd5c6372b0c
> Author: Bruce Allan <bruce.w.allan@intel.com>
> Date: =A0 Tue Aug 26 18:37:06 2008 -0700
>
> =A0 =A0e1000e: add support for new 82574L part
>
> =A0 =A0This new part has the same feature set as previous parts with =
the addition
> =A0 =A0of MSI-X support.
>
> =A0 =A0Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> =A0 =A0Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>
> MSI-X support was added to the e1000e driver, later on slightly rewor=
ked by:
>
> commit 8e86acd7d5968e08b3e1604e685a8c45f6fd7f40
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon Aug 2 14:27:23 2010 +0000
>
> =A0 =A0e1000e: Fix irq_synchronize in MSI-X case
>
> =A0 =A0Based on original patch/work from Jean Delvare <jdelvare@suse.=
de>
> =A0 =A0Synchronize all IRQs when in MSI-X IRQ mode.
>
> =A0 =A0Jean's original patch hard coded the sync with the 3 possible =
vectors,
> =A0 =A0this patch incorporates more flexibility for the future and al=
igns
> =A0 =A0with how igb stores the number of vectors into the adapter str=
ucture.
>
> =A0 =A0CC: Jean Delvare <jdelvare@suse.de>
> =A0 =A0Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> =A0 =A0Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> =A0 =A0Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> [It is unclear to what "Jean" does this commit log refers to, as the
> support MSI-X was added Bruce, anyway...]
>
> Why only 3 vectors are used when both the product brief and the
> datasheet advertise up to 5 MSI-X vector usable by the chip ? That is
> 2*RX + 2*TX.
>
> Thanks in advance,
> =A0- Arnaud
>
