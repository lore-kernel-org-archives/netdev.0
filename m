From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [PATCH 01/11] Removing dead RT2800PCI_SOC
Date: Wed, 14 Jul 2010 16:14:55 +0200
Message-ID: <201007141614.55756.bzolnier@gmail.com>
References: <cover.1279110894.git.siccegge@cs.fau.de> <AANLkTinO32CIe0HBTXjP_bcAz0nMEw6wvcZwcob1fX3r@mail.gmail.com> <AANLkTikCeDys9e1EnE9GdiJtDRcbqW3gzvsmjzvB_yDs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Egger <siccegge@cs.fau.de>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de,
	Luis Correia <luis.f.correia@gmail.com>
To: Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65438 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465Ab0GNOPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 10:15:37 -0400
In-Reply-To: <AANLkTikCeDys9e1EnE9GdiJtDRcbqW3gzvsmjzvB_yDs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 14 July 2010 02:52:14 pm Ivo Van Doorn wrote:
> On Wed, Jul 14, 2010 at 2:46 PM, Luis Correia <luis.f.correia@gmail.com> wrote:
> > On Wed, Jul 14, 2010 at 13:39, Christoph Egger <siccegge@cs.fau.de> wrote:
> >> While RT2800PCI_SOC exists in Kconfig, it depends on either
> >> RALINK_RT288X or RALINK_RT305X which are both not available in Kconfig
> >> so all Code depending on that can't ever be selected and, if there's
> >> no plan to add these options, should be cleaned up
> >>
> >> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
> >
> > NAK,
> >
> > this is not dead code, it is needed for the Ralink System-on-Chip
> > Platform devices.
> >
> > While I can't fix Kconfig errors and the current KConfig file may be
> > wrong, this code cannot and will not be deleted.
> 
> When the config option was introduced, the config options RALINK_RT288X and
> RALINK_RT305X were supposed to be merged as well soon after by somebody (Felix?)
> 
> But since testing is done on SoC boards by Helmut and Felix, I assume the code
> isn't dead but actually in use.
> 
> Ivo

I fully agree with Luis and Ivo that the proposed patch is invalid and
shouldn't be applied (the "code cannot and will not be deleted" anyway)..

[ Under "The New Normal" rules the code doesn't even have to work to be
  merged and/or stay in the kernel so 9 months of code not being used by
  any real user doesn't matter a tiny bit.. ]

--
Bartlomiej Zolnierkiewicz
