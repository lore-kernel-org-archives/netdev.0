From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 8/8] rfkill: Factor common code
Date: Tue, 19 Jan 2016 15:32:13 -0500
Message-ID: <CA+A7VXWEp9WAFirRpwpkLheSWv9=XJMfSrgF2LgX7evrYj5aOQ@mail.gmail.com>
References: <1453218163-31998-9-git-send-email-jprvita@endlessm.com> <201601200135.n1cR5fZx%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kbuild-all@01.org, Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>,
	linux@endlessm.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f195.google.com ([209.85.160.195]:36063 "EHLO
	mail-yk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932734AbcASUcx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 15:32:53 -0500
In-Reply-To: <201601200135.n1cR5fZx%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 January 2016 at 12:39, kbuild test robot <lkp@intel.com> wrote:
> Hi Jo=C3=A3o,
>
> [auto build test ERROR on mac80211-next/master]
> [also build test ERROR on v4.4 next-20160119]
> [if your patch is applied to the wrong git tree, please drop us a not=
e to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Jo-o-Paulo-Rechi-Vit=
a/General-RFKill-improvements/20160119-234934
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac8021=
1-next.git master
> config: i386-randconfig-s0-201603 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=3Di386
>
> All errors (new ones prefixed by >>):
>
>    net/built-in.o: In function `rfkill_sync_work':
>>> core.c:(.text+0x13d849): undefined reference to `rfkill_get_global_=
sw_state'
>

I've overlooked the fact that rfkill_get_global_sw_state() is inside a
#ifdef block -- I'll fix this in an updated version.
