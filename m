From: Ivo Van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 01/11] Removing dead RT2800PCI_SOC
Date: Wed, 14 Jul 2010 14:52:14 +0200
Message-ID: <AANLkTikCeDys9e1EnE9GdiJtDRcbqW3gzvsmjzvB_yDs@mail.gmail.com>
References: <cover.1279110894.git.siccegge@cs.fau.de>
	<29013fb6eab9e95e95d61df894797d2455dfa10c.1279110894.git.siccegge@cs.fau.de>
	<AANLkTinO32CIe0HBTXjP_bcAz0nMEw6wvcZwcob1fX3r@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de,
	Luis Correia <luis.f.correia@gmail.com>
To: Christoph Egger <siccegge@cs.fau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56589 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab0GNMwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:52:17 -0400
In-Reply-To: <AANLkTinO32CIe0HBTXjP_bcAz0nMEw6wvcZwcob1fX3r@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 14, 2010 at 2:46 PM, Luis Correia <luis.f.correia@gmail.com> wrote:
> On Wed, Jul 14, 2010 at 13:39, Christoph Egger <siccegge@cs.fau.de> wrote:
>> While RT2800PCI_SOC exists in Kconfig, it depends on either
>> RALINK_RT288X or RALINK_RT305X which are both not available in Kconfig
>> so all Code depending on that can't ever be selected and, if there's
>> no plan to add these options, should be cleaned up
>>
>> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
>
> NAK,
>
> this is not dead code, it is needed for the Ralink System-on-Chip
> Platform devices.
>
> While I can't fix Kconfig errors and the current KConfig file may be
> wrong, this code cannot and will not be deleted.

When the config option was introduced, the config options RALINK_RT288X and
RALINK_RT305X were supposed to be merged as well soon after by somebody (Felix?)

But since testing is done on SoC boards by Helmut and Felix, I assume the code
isn't dead but actually in use.

Ivo
