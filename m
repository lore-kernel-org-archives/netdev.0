From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCHv2 00/10] RFKill airplane-mode indicator
Date: Mon, 22 Feb 2016 11:00:20 -0600
Message-ID: <1456160420.16083.3.camel@redhat.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-02-22 at 11:36 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
> This series implements an airplane-mode indicator LED trigger, which
> can be
> used by platform drivers. The default policy have have airplane-mode
> set when
> all the radios known by RFKill are OFF, and unset otherwise. This
> policy can be
> overwritten by one single userspace application at a time using the
> operations
> _AIRPLANE_MODE_INDICATOR_ACQUIRE and _AIRPLANE_MODE_INDICATOR_CHANGE.
>=20
Double-check your commit messages on some of these patches; they didn't
get updated to add INDICATOR.

Dan

> When the
> airplane-mode indicator state changes, userspace gets notifications
> through the
> RFKill control misc device (/dev/rfkill).
>=20
> The series also contains a few general fixes and improvements to the
> subsystem.
>=20
> Additionally, I have a couple of patches to have this feature
> supported by the
> userspace tool 'rfkill' [1]. Should I use a different subject prefix
> to help
> separate those from kernel patches in linux-wireless?
>=20
> [1] https://wireless.wiki.kernel.org/en/users/documentation/rfkill
>=20
> Jo=C3=A3o Paulo Rechi Vita (10):
> =C2=A0 rfkill: Improve documentation language
> =C2=A0 rfkill: Remove extra blank line
> =C2=A0 rfkill: Point to the correct deprecated doc location
> =C2=A0 rfkill: Move "state" sysfs file back to stable
> =C2=A0 rfkill: Factor rfkill_global_states[].cur assignments
> =C2=A0 rfkill: Add documentation about LED triggers
> =C2=A0 rfkill: Create "rfkill-airplane-mode" LED trigger
> =C2=A0 rfkill: Use switch to demux userspace operations
> =C2=A0 rfkill: Userspace control for airplane mode
> =C2=A0 rfkill: Notify userspace of airplane-mode state changes
>=20
> =C2=A0Documentation/ABI/obsolete/sysfs-class-rfkill |=C2=A0=C2=A020 -=
---
> =C2=A0Documentation/ABI/stable/sysfs-class-rfkill=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A027 ++++-
> =C2=A0Documentation/rfkill.txt=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A017 +++
> =C2=A0include/uapi/linux/rfkill.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0|=C2=A0=C2=A0=C2=A06 +
> =C2=A0net/rfkill/core.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 162
> ++++++++++++++++++++------
> =C2=A05 files changed, 173 insertions(+), 59 deletions(-)
> =C2=A0delete mode 100644 Documentation/ABI/obsolete/sysfs-class-rfkil=
l
>=20
