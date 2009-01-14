From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [PATCH 07/16] dma-debug: add debugfs interface
Date: Wed, 14 Jan 2009 16:22:16 +0100
Message-ID: <20090114152216.GM20283@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-8-git-send-email-joerg.roedel@amd.com> <20090110230826.GJ17917@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-va3.frontbridge.com ([216.32.180.16]:58364 "EHLO
	VA3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757468AbZANPWh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 10:22:37 -0500
Content-Disposition: inline
In-Reply-To: <20090110230826.GJ17917@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 12:08:26AM +0100, Ingo Molnar wrote:
>=20
> * Joerg Roedel <joerg.roedel@amd.com> wrote:
>=20
> > +/* Global error count */
> > +static u32 error_count;
> > +
> > +/* Global error show enable*/
> > +static u32 show_all_errors __read_mostly;
> > +/* Number of errors to show */
> > +static u32 show_num_errors =3D 1;
> > +
> >  static u32 num_free_entries;
> >  static u32 min_free_entries;
>=20
> Small detail: please use native C types for non-hardware variables -=20
> 'unsigned int', 'unsigned long', etc.
>=20
> u32/u64 is typically used for variables where there is a real signifi=
cance=20
> to the precise width of the variable: there's either a hardware or a=20
> user-space ABI involved.

There is some kind of userspace ABI: all these variables are exported
via debugfs. And debugfs relies on these types.

Joerg

--=20
           | Advanced Micro Devices GmbH
 Operating | Karl-Hammerschmidt-Str. 34, 85609 Dornach bei M=C3=BCnchen
 System    |=20
 Research  | Gesch=C3=A4ftsf=C3=BChrer: Jochen Polster, Thomas M. McCoy=
, Giuliano Meroni
 Center    | Sitz: Dornach, Gemeinde Aschheim, Landkreis M=C3=BCnchen
           | Registergericht M=C3=BCnchen, HRB Nr. 43632

