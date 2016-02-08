From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 0/9] RFKill airplane-mode indicator
Date: Mon,  8 Feb 2016 10:41:27 -0500
Message-ID: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series implements an airplane-mode indicator LED trigger, which ca=
n be
used by platform drivers. The default policy have have airplane-mode se=
t when
all the radios known by RFKill are OFF, and unset otherwise. This polic=
y can be
overwritten by userspace using the new operations _AIRPLANE_MODE_ACQUIR=
E,
_AIRPLANE_MODE_RELEASE, and _AIRPLANE_MODE_CHANGE. When the airplane-mo=
de
indicator state changes, userspace gets notifications through the RFKil=
l
control misc device (/dev/rfkill).

The series also contains a few general fixes and improvements to the su=
bsystem.

Jo=C3=A3o Paulo Rechi Vita (9):
  rfkill: Improve documentation language
  rfkill: Remove extra blank line
  rfkill: Point to the correct deprecated doc location
  rfkill: Move "state" sysfs file back to stable
  rfkill: Factor rfkill_global_states[].cur assignments
  rfkill: Add documentation about LED triggers
  rfkill: Create "rfkill-airplane_mode" LED trigger
  rfkill: Userspace control for airplane mode
  rfkill: Notify userspace of airplane-mode state changes

 Documentation/ABI/obsolete/sysfs-class-rfkill |  20 ----
 Documentation/ABI/stable/sysfs-class-rfkill   |  27 ++++-
 Documentation/rfkill.txt                      |  17 +++
 include/uapi/linux/rfkill.h                   |   3 +
 net/rfkill/core.c                             | 144 ++++++++++++++++++=
+++-----
 5 files changed, 164 insertions(+), 47 deletions(-)
 delete mode 100644 Documentation/ABI/obsolete/sysfs-class-rfkill

--=20
2.5.0

