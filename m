From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 10:16:27 +0000
Message-ID: <CAKh2mn5UGRN5U0w_bj25e4VnCwr9kK3f798nHSwmF4WE4dORMw@mail.gmail.com>
References: <87y5hm9ap5.fsf@nemi.mork.no>
	<Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
	<CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
	<874nka3wgx.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:34636 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab2K1KQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 05:16:28 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so5195257eaa.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 02:16:27 -0800 (PST)
In-Reply-To: <874nka3wgx.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjorn,

On 28 November 2012 09:31, Bj=F8rn Mork <bjorn@mork.no> wrote:
>
> Remote wakeup will not be enabled on system suspend unless the user (=
or
> a userspace program on the users behalf) has requested it.

If a user types "ethtool -s eth2 wol p" they *are* explicitly
requesting the ethernet device to bring the system out of suspend, so
I think the ethernet driver should set the feature automatically.

from drivers/base/power/wakeup.c:

 * By default, most devices should leave wakeup disabled.  The exceptio=
ns are
 * devices that everyone expects to be wakeup sources: keyboards, power=
 buttons,
 * possibly network interfaces, etc.

Steve
