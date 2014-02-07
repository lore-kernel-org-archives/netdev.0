From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 02/26] drivers: isdn: Move prototype declaration to header
 file um_idi.h from um_idi.c
Date: Fri, 7 Feb 2014 17:49:09 +0530
Message-ID: <a38afb37d39385b9dc4eac5c351b7b46048a873e.1390408513.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of functions to header file
hardware/eicon/um_idi.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/divasi.c:
drivers/isdn/hardware/eicon/divasi.c:446:6: warning: no previous protot=
ype for =E2=80=98diva_os_wakeup_read=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/divasi.c:453:6: warning: no previous protot=
ype for =E2=80=98diva_os_wakeup_close=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/um_idi.c |    5 -----
 drivers/isdn/hardware/eicon/um_idi.h |    2 ++
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/um_idi.c b/drivers/isdn/hardwa=
re/eicon/um_idi.c
index e151971..676663a 100644
--- a/drivers/isdn/hardware/eicon/um_idi.c
+++ b/drivers/isdn/hardware/eicon/um_idi.c
@@ -14,11 +14,6 @@
 #define DIVAS_MAX_XDI_ADAPTERS	64
=20
 /* -------------------------------------------------------------------=
-------
-   IMPORTS
-   -------------------------------------------------------------------=
------- */
-extern void diva_os_wakeup_read(void *os_context);
-extern void diva_os_wakeup_close(void *os_context);
-/* -------------------------------------------------------------------=
-------
    LOCALS
    -------------------------------------------------------------------=
------- */
 static LIST_HEAD(adapter_q);
diff --git a/drivers/isdn/hardware/eicon/um_idi.h b/drivers/isdn/hardwa=
re/eicon/um_idi.h
index ffb88f7..00ca1e7 100644
--- a/drivers/isdn/hardware/eicon/um_idi.h
+++ b/drivers/isdn/hardware/eicon/um_idi.h
@@ -34,6 +34,8 @@ int diva_um_idi_write(void *entity,
 int diva_user_mode_idi_ind_ready(void *entity, void *os_handle);
 void *diva_um_id_get_os_context(void *entity);
 int diva_os_get_context_size(void);
+void diva_os_wakeup_read(void *os_context);
+void diva_os_wakeup_close(void *os_context);
 int divas_um_idi_entity_assigned(void *entity);
 int divas_um_idi_entity_start_remove(void *entity);
=20
--=20
1.7.9.5
