From: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>
Subject: Re: [PATCH 11/15] net: mac80211: Fix a typo.
Date: Thu, 5 Aug 2010 16:44:58 +0200
Message-ID: <AANLkTimU7BLxysdKqAZpFLSkNnvM4jCSb-BbUc0RGjAn@mail.gmail.com>
References: <1281016299-23958-1-git-send-email-andrea.gelmini@gelma.net>
	<1281016299-23958-11-git-send-email-andrea.gelmini@gelma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gelma@gelma.net, Stefano Brivio <stefano.brivio@polimi.it>,
	Mattias Nissler <mattias.nissler@gmx.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrea Gelmini <andrea.gelmini@gelma.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:53782 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933322Ab0HEOpU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 10:45:20 -0400
In-Reply-To: <1281016299-23958-11-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 5, 2010 at 3:51 PM, Andrea Gelmini <andrea.gelmini@gelma.ne=
t> wrote:
> "userpace" -> "userspace"
>
> Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
> ---
> =A0net/mac80211/rc80211_pid_debugfs.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/mac80211/rc80211_pid_debugfs.c b/net/mac80211/rc8021=
1_pid_debugfs.c
> index 47438b4..135f36f 100644
> --- a/net/mac80211/rc80211_pid_debugfs.c
> +++ b/net/mac80211/rc80211_pid_debugfs.c
> @@ -162,7 +162,7 @@ static ssize_t rate_control_pid_events_read(struc=
t file *file, char __user *buf,
> =A0 =A0 =A0 =A0file_info->next_entry =3D (file_info->next_entry + 1) =
%
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RC_PID=
_EVENT_RING_SIZE;
>
> - =A0 =A0 =A0 /* Print information about the event. Note that userpac=
e needs to
> + =A0 =A0 =A0 /* Print information about the event. Note that userspa=
ce needs to
> =A0 =A0 =A0 =A0 * provide large enough buffers. */
> =A0 =A0 =A0 =A0length =3D length < RC_PID_PRINT_BUF_SIZE ?
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 length : RC_PID_PRINT_BUF_SIZE;

length =3D min(length, RC_PID_PRINT_BUF_SIZE) maybe? (Though this is no=
t
part of the patch.)

> --
> 1.7.2.1.85.g2d089
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Vista: [V]iruses, [I]ntruders, [S]pyware, [T]rojans and [A]dware. :-)
