From: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
	driver.
Date: Sat, 10 Oct 2009 20:05:27 +0200
Message-ID: <1ba2fa240910101105y77171591j32e6759f28556566@mail.gmail.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1255172508.19127.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1255172508.19127.22.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 10, 2009 at 1:01 PM, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> =
wrote:
> Hi Tomas,
>
>> This patch adds Intel Wireless MultiCom 3200 top driver.
>> IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
>> Top driver is responsible for device initialization and firmware dow=
nload.
>> Firmware handled by top is responsible for top itself and
>> as well as bluetooth and GPS coms. (Wifi and WiMax provide their own
>> firmware)
>> In addition top driver is used to retrieve firmware logs
>> and supports other debugging features
>>
>> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> ---
>> =C2=A0drivers/misc/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A01 +
>> =C2=A0drivers/misc/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
>> =C2=A0drivers/misc/iwmc3200top/Kconfig =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 20 +
>> =C2=A0drivers/misc/iwmc3200top/Makefile =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 29 ++
>> =C2=A0drivers/misc/iwmc3200top/debugfs.c =C2=A0 =C2=A0 | =C2=A0145 +=
++++++
>> =C2=A0drivers/misc/iwmc3200top/debugfs.h =C2=A0 =C2=A0 | =C2=A0 61 +=
++
>> =C2=A0drivers/misc/iwmc3200top/fw-download.c | =C2=A0359 +++++++++++=
+++++
>> =C2=A0drivers/misc/iwmc3200top/fw-msg.h =C2=A0 =C2=A0 =C2=A0| =C2=A0=
113 +++++
>> =C2=A0drivers/misc/iwmc3200top/iwmc3200top.h | =C2=A0202 +++++++++
>> =C2=A0drivers/misc/iwmc3200top/log.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0339 +++++++++++++++
>> =C2=A0drivers/misc/iwmc3200top/log.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0158 +++++++
>> =C2=A0drivers/misc/iwmc3200top/main.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0702 ++++++++++++++++++++++++++++++++
>> =C2=A012 files changed, 2130 insertions(+), 0 deletions(-)
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/Kconfig
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/Makefile
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/debugfs.c
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/debugfs.h
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/fw-download.c
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/fw-msg.h
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/iwmc3200top.h
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/log.c
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/log.h
>> =C2=A0create mode 100644 drivers/misc/iwmc3200top/main.c
>>
>> diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
>> index 68ab39d..6f85b43 100644
>> --- a/drivers/misc/Kconfig
>> +++ b/drivers/misc/Kconfig
>> @@ -236,5 +236,6 @@ config ISL29003
>> =C2=A0source "drivers/misc/c2port/Kconfig"
>> =C2=A0source "drivers/misc/eeprom/Kconfig"
>> =C2=A0source "drivers/misc/cb710/Kconfig"
>> +source "drivers/misc/iwmc3200top/Kconfig"
>>
>> =C2=A0endif # MISC_DEVICES
>> diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
>> index 36f733c..97f5303 100644
>> --- a/drivers/misc/Makefile
>> +++ b/drivers/misc/Makefile
>> @@ -20,5 +20,6 @@ obj-$(CONFIG_SGI_GRU) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 +=3D sgi-gru/
>> =C2=A0obj-$(CONFIG_HP_ILO) =C2=A0 =C2=A0 =C2=A0 =C2=A0 +=3D hpilo.o
>> =C2=A0obj-$(CONFIG_ISL29003) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 +=3D isl29003.o
>> =C2=A0obj-$(CONFIG_C2PORT) =C2=A0 =C2=A0 =C2=A0 =C2=A0 +=3D c2port/
>> +obj-$(CONFIG_IWMC3200TOP) =C2=A0 =C2=A0 =C2=A0+=3D iwmc3200top/
>> =C2=A0obj-y =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0+=3D eeprom/
>> =C2=A0obj-y =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0+=3D cb710/
>> diff --git a/drivers/misc/iwmc3200top/Kconfig b/drivers/misc/iwmc320=
0top/Kconfig
>> new file mode 100644
>> index 0000000..9e4b88f
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/Kconfig
>> @@ -0,0 +1,20 @@
>> +config IWMC3200TOP
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0tristate "Intel Wireless MultiCom Top D=
river"
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on MMC && EXPERIMENTAL
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0select FW_LOADER
>> + =C2=A0 =C2=A0 ---help---
>> + =C2=A0 =C2=A0 =C2=A0 Intel Wireless MultiCom 3200 Top driver is re=
sponsible for
>> + =C2=A0 =C2=A0 =C2=A0 for firmware load and enabled coms enumeratio=
n
>> +
>> +config IWMC3200TOP_DEBUG
>> + =C2=A0 =C2=A0 bool "Enable full debug output of iwmc3200top Driver=
"
>> + =C2=A0 =C2=A0 depends on IWMC3200TOP
>> + =C2=A0 =C2=A0 ---help---
>> + =C2=A0 =C2=A0 =C2=A0 Enable full debug output of iwmc3200top Drive=
r
>> +
>> +config IWMC3200TOP_DEBUGFS
>> + =C2=A0 =C2=A0 bool "Enable Debugfs debugging interface for iwmc320=
0top"
>> + =C2=A0 =C2=A0 depends on IWMC3200TOP
>> + =C2=A0 =C2=A0 ---help---
>> + =C2=A0 =C2=A0 =C2=A0 Enable creation of debugfs files for iwmc3200=
top
>> +
>> diff --git a/drivers/misc/iwmc3200top/Makefile b/drivers/misc/iwmc32=
00top/Makefile
>> new file mode 100644
>> index 0000000..fbf53fb
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/Makefile
>> @@ -0,0 +1,29 @@
>> +# iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> +# drivers/misc/iwmc3200top/Makefile
>> +#
>> +# Copyright (C) 2009 Intel Corporation. All rights reserved.
>> +#
>> +# This program is free software; you can redistribute it and/or
>> +# modify it under the terms of the GNU General Public License versi=
on
>> +# 2 as published by the Free Software Foundation.
>> +#
>> +# This program is distributed in the hope that it will be useful,
>> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
>> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See th=
e
>> +# GNU General Public License for more details.
>> +#
>> +# You should have received a copy of the GNU General Public License
>> +# along with this program; if not, write to the Free Software
>> +# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> +# 02110-1301, USA.
>> +#
>> +#
>> +# Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> +# =C2=A0-
>> +#
>> +#
>> +
>> +obj-$(CONFIG_IWMC3200TOP) =C2=A0 =C2=A0+=3D iwmc3200top.o
>> +iwmc3200top-objs =C2=A0 =C2=A0 :=3D main.o fw-download.o
>> +iwmc3200top-$(CONFIG_IWMC3200TOP_DEBUG) +=3D log.o
>> +iwmc3200top-$(CONFIG_IWMC3200TOP_DEBUGFS) +=3D debugfs.o
>> diff --git a/drivers/misc/iwmc3200top/debugfs.c b/drivers/misc/iwmc3=
200top/debugfs.c
>> new file mode 100644
>> index 0000000..a531f6c
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/debugfs.c
>> @@ -0,0 +1,145 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/debufs.c
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/string.h>
>> +#include <linux/ctype.h>
>> +#include <linux/mmc/sdio_func.h>
>> +#include <linux/mmc/sdio.h>
>> +
>> +#include "iwmc3200top.h"
>> +#include "log.h"
>> +#include "fw-msg.h"
>> +#include "debugfs.h"
>> +
>> +/* =C2=A0 =C2=A0 =C2=A0Constants definition =C2=A0 =C2=A0 =C2=A0 =C2=
=A0*/
>> +#define HEXADECIMAL_RADIX =C2=A0 =C2=A016
>> +
>> +/* =C2=A0 =C2=A0 =C2=A0Functions definition =C2=A0 =C2=A0 =C2=A0 =C2=
=A0*/
>> +
>> +
>> +/* =C2=A0 =C2=A0 =C2=A0Debugfs macros =C2=A0 =C2=A0 =C2=A0 */
>> +#define DEBUGFS_ADD_DIR(name, parent) do { =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 dbgfs->dir_##name =3D debugfs_create_dir(#name, pare=
nt); =C2=A0\
>> + =C2=A0 =C2=A0 if (!(dbgfs->dir_##name)) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err; =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> +} while (0)
>> +
>> +#define DEBUGFS_ADD_FILE(name, parent) do { =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 dbgfs->dbgfs_##parent##_files.file_##name =3D =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 debugfs_create_file(#name, 0644, dbgfs->dir_##parent=
, priv, =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &iwmct_dbgfs_##name##_ops); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 if (!(dbgfs->dbgfs_##parent##_files.file_##name)) =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err; =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 \
>> +} while (0)
>> +
>> +#define DEBUGFS_REMOVE(name) =C2=A0do { =C2=A0 \
>> + =C2=A0 =C2=A0 debugfs_remove(name); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 \
>> + =C2=A0 =C2=A0 name =3D NULL; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> +} while (0)
>> +
>> +#define DEBUGFS_READ_FUNC(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> +ssize_t iwmct_dbgfs_##name##_read(struct file *file, =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 char __user *user_buf, =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t count, loff_t *ppos);
>> +
>> +#define DEBUGFS_WRITE_FUNC(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 \
>> +ssize_t iwmct_dbgfs_##name##_write(struct file *file, =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const char __user *user_bu=
f, =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t count, loff_t *ppos=
);
>> +
>> +#define DEBUGFS_READ_FILE_OPS(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 DEBUGFS_READ_FUNC(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 static const struct file_operations iwmct_dbgfs_##na=
me##_ops =3D { =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read =3D iwmct_dbgfs_##=
name##_read, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .open =3D iwmct_dbgfs_op=
en_file_generic, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0\
>> + =C2=A0 =C2=A0 };
>> +
>> +#define DEBUGFS_WRITE_FILE_OPS(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 \
>> + =C2=A0 =C2=A0 DEBUGFS_WRITE_FUNC(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 static const struct file_operations iwmct_dbgfs_##na=
me##_ops =3D { =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write =3D iwmct_dbgfs_#=
#name##_write, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .open =3D iwmct_dbgfs_op=
en_file_generic, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0\
>> + =C2=A0 =C2=A0 };
>> +
>> +#define DEBUGFS_READ_WRITE_FILE_OPS(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 DEBUGFS_READ_FUNC(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 DEBUGFS_WRITE_FUNC(name) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 static const struct file_operations iwmct_dbgfs_##na=
me##_ops =3D {\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .write =3D iwmct_dbgfs_#=
#name##_write, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read =3D iwmct_dbgfs_##=
name##_read, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .open =3D iwmct_dbgfs_op=
en_file_generic, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0\
>> + =C2=A0 =C2=A0 };
>> +
>> +
>> +/* =C2=A0 =C2=A0 =C2=A0Debugfs file ops definitions =C2=A0 =C2=A0 =C2=
=A0 =C2=A0*/
>> +
>> +/* =C2=A0 =C2=A0 =C2=A0Debugfs registration functions =C2=A0 =C2=A0=
 =C2=A0 =C2=A0*/
>> +
>> +/*
>> + * Create the debugfs files and directories
>> + *
>> + */
>
> so for me the whole debug infrastructure is way too much overhead for
> what this driver has to achieve. What is the benefit of having all th=
ese
> debugfs support. What is it trying to achieve?

There is some testing infrastracture built erround debugfs, it
exericeses the firmware. There is no use for
it outside our development so we ripped it off but removing also
debugfs will nightmare to maintain.
>
> Also all these macros really obfuscate the code for no real benefit. =
If
> you wanna keep debugfs support, then just use the functions directly.
> They are not that complicated that an extra abstraction layer is need=
ed.
>
I believe the macros were  borrowed from wireless code.  They shalll
reduce codelines
but I have no strong feelings about them

Thanks for your comments I will address them in consequitve patch.

Thanks
Tomas

>> +void iwmct_dbgfs_register(struct iwmct_priv *priv, const char *name=
)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_debugfs *dbgfs;
>> +
>> + =C2=A0 =C2=A0 dbgfs =3D kzalloc(sizeof(struct iwmct_debugfs), GFP_=
KERNEL);
>> + =C2=A0 =C2=A0 if (!dbgfs) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, DEBUGFS,=
 "failed to allocate %zd bytes\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sizeof(stru=
ct iwmct_debugfs));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 priv->dbgfs =3D dbgfs;
>> + =C2=A0 =C2=A0 dbgfs->name =3D name;
>> + =C2=A0 =C2=A0 dbgfs->dir_drv =3D debugfs_create_dir(name, NULL);
>> + =C2=A0 =C2=A0 if (!dbgfs->dir_drv) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, DEBUGFS,=
 "failed to create debugfs dir\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
>> + =C2=A0 =C2=A0 }
>> +
>> +
>> +err:
>> + =C2=A0 =C2=A0 return;
>> +}
>
> goto err. Seriously. Just call return in the error case. And also the=
re
> is a memory leak if the debugfs_create_dir fails.
>

>> +/**
>> + * Remove the debugfs files and directories
>> + *
>> + */
>> +void iwmct_dbgfs_unregister(struct iwmct_debugfs *dbgfs)
>> +{
>> + =C2=A0 =C2=A0 if (!dbgfs)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> +
>> + =C2=A0 =C2=A0 DEBUGFS_REMOVE(dbgfs->dir_drv);
>> + =C2=A0 =C2=A0 kfree(dbgfs);
>> +
>> + =C2=A0 =C2=A0 dbgfs =3D NULL;
>> +}
>> +
>> diff --git a/drivers/misc/iwmc3200top/debugfs.h b/drivers/misc/iwmc3=
200top/debugfs.h
>> new file mode 100644
>> index 0000000..24b1369
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/debugfs.h
>> @@ -0,0 +1,61 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/debufs.h
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#ifndef __DEBUGFS_H__
>> +#define __DEBUGFS_H__
>> +
>> +
>> +#ifdef CONFIG_IWMC3200TOP_DEBUGFS
>> +
>> +#include <linux/debugfs.h>
>> +
>> +struct iwmct_debugfs {
>> + =C2=A0 =C2=A0 const char *name;
>> + =C2=A0 =C2=A0 struct dentry *dir_drv;
>> + =C2=A0 =C2=A0 struct dir_drv_files {
>> + =C2=A0 =C2=A0 } dbgfs_drv_files;
>> +};
>> +
>> +void iwmct_dbgfs_register(struct iwmct_priv *priv, const char *name=
);
>> +void iwmct_dbgfs_unregister(struct iwmct_debugfs *dbgfs);
>> +
>> +#else /* CONFIG_IWMC3200TOP_DEBUGFS */
>> +
>> +/* struct iwmct_debugfs is empty if CONFIG_IWMC3200TOP_DEBUGFS is n=
ot defined */
>> +struct iwmct_debugfs {
>> +};
>
> If struct iwmct_debugfs is never referenced directly then a simple
> forward struct imwct_debugfs; declaration is good enough.
>
>> +
>> +static inline void
>> +iwmct_dbgfs_register(struct iwmct_priv *priv, const char *name)
>> +{}
>> +
>> +static inline void iwmct_dbgfs_unregister(struct iwmct_debugfs *dbg=
fs)
>> +{}
>> +
>> +#endif /* CONFIG_IWMC3200TOP_DEBUGFS */
>> +
>> +#endif /* __DEBUGFS_H__ */
>> +
>> diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/i=
wmc3200top/fw-download.c
>> new file mode 100644
>> index 0000000..33cb693
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/fw-download.c
>> @@ -0,0 +1,359 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/fw-download.c
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#include <linux/firmware.h>
>> +#include <linux/mmc/sdio_func.h>
>> +#include <asm/unaligned.h>
>> +
>> +#include "iwmc3200top.h"
>> +#include "log.h"
>> +#include "fw-msg.h"
>> +
>> +#define CHECKSUM_BYTES_NUM sizeof(u32)
>> +
>> +/**
>> + =C2=A0init parser struct with file
>> + */
>> +static int iwmct_fw_parser_init(struct iwmct_priv *priv, const u8 *=
file,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 size_t file_size, size_t block_size)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_parser *parser =3D &priv->parser;
>> + =C2=A0 =C2=A0 struct iwmct_fw_hdr *fw_hdr =3D &parser->versions;
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "-->\n");
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLOAD, "file_size=3D%zd\n", fil=
e_size);
>
> This logging is overkill. Can we just hide this via pr_debug and then
> use just simply dynamic_printk support.
>
>> +
>> + =C2=A0 =C2=A0 parser->file =3D file;
>> + =C2=A0 =C2=A0 parser->file_size =3D file_size;
>> + =C2=A0 =C2=A0 parser->cur_pos =3D 0;
>> + =C2=A0 =C2=A0 parser->buf =3D NULL;
>> +
>> + =C2=A0 =C2=A0 parser->buf =3D kzalloc(block_size, GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!parser->buf) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_DOWNL=
OAD, "kzalloc error\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 parser->buf_size =3D block_size;
>> +
>> + =C2=A0 =C2=A0 /* extract fw versions */
>> + =C2=A0 =C2=A0 memcpy(fw_hdr, parser->file, sizeof(struct iwmct_fw_=
hdr));
>> + =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLOAD, "fw versions are:\n"
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "top %u.%u.%u gps %u.%u.=
%u bt %u.%u.%u tic %s\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fw_hdr->top_major, fw_hd=
r->top_minor, fw_hdr->top_revision,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fw_hdr->gps_major, fw_hd=
r->gps_minor, fw_hdr->gps_revision,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fw_hdr->bt_major, fw_hdr=
->bt_minor, fw_hdr->bt_revision,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fw_hdr->tic_name);
>> +
>> + =C2=A0 =C2=A0 parser->cur_pos +=3D sizeof(struct iwmct_fw_hdr);
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "<--\n");
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +static bool iwmct_checksum(struct iwmct_priv *priv)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_parser *parser =3D &priv->parser;
>> + =C2=A0 =C2=A0 __le32 *file =3D (__le32 *)parser->file;
>> + =C2=A0 =C2=A0 int i, pad, steps;
>> + =C2=A0 =C2=A0 u32 accum =3D 0;
>> + =C2=A0 =C2=A0 u32 checksum;
>> + =C2=A0 =C2=A0 u32 mask =3D 0xffffffff;
>> +
>> + =C2=A0 =C2=A0 pad =3D (parser->file_size - CHECKSUM_BYTES_NUM) % 4=
;
>> + =C2=A0 =C2=A0 steps =3D =C2=A0(parser->file_size - CHECKSUM_BYTES_=
NUM) / 4;
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLOAD, "pad=3D%d steps=3D%d\n",=
 pad, steps);
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; i < steps; i++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 accum +=3D le32_to_cpu(f=
ile[i]);
>> +
>> + =C2=A0 =C2=A0 if (pad) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mask <<=3D 8 * (4 - pad)=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 accum +=3D le32_to_cpu(f=
ile[steps]) & mask;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 checksum =3D get_unaligned_le32((__le32 *)(parser->f=
ile +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 parser->file_size - CHECKSUM_BYTES_NUM));
>
> The access to file and parser->file. One with unaligned access and th=
e
> other with, looks wrong. And it looks way to complicated.
>
> Can we just not have a proper __le32 type of parser->file to begin wi=
th.
>
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLOAD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "compare checksum accum=3D=
0x%x to checksum=3D0x%x\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 accum, checksum);
>> +
>> + =C2=A0 =C2=A0 return checksum =3D=3D accum;
>> +}
>> +
>> +static int iwmct_parse_next_section(struct iwmct_priv *priv, const =
u8 **p_sec,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t *sec_size, __le32 *sec_ad=
dr)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_parser *parser =3D &priv->parser;
>> + =C2=A0 =C2=A0 struct iwmct_dbg *dbg =3D &priv->dbg;
>> + =C2=A0 =C2=A0 struct iwmct_fw_sec_hdr *sec_hdr;
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "-->\n");
>> +
>> + =C2=A0 =C2=A0 while (parser->cur_pos + sizeof(struct iwmct_fw_sec_=
hdr)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 <=3D parser->file_size) =
{
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sec_hdr =3D (struct iwmc=
t_fw_sec_hdr *)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (parser->file + parser->cur_pos);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 parser->cur_pos +=3D siz=
eof(struct iwmct_fw_sec_hdr);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLO=
AD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "sec hdr: type=3D%s addr=3D0x%x size=3D%d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 sec_hdr->type, sec_hdr->target_addr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 sec_hdr->data_size);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (strcmp(sec_hdr->type=
, "ENT") =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 parser->entry_point =3D le32_to_cpu(sec_hdr->target_addr);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (strcmp(sec_hdr-=
>type, "LBL") =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 strcpy(dbg->label_fw, parser->file + parser->cur_pos);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (((strcmp(sec_hd=
r->type, "TOP") =3D=3D 0) &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 (priv->barker & BARKER_DNLOAD_TOP_MSK)) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0((strcmp(sec_hdr->type, "GPS") =3D=3D 0) &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 (priv->barker & BARKER_DNLOAD_GPS_MSK)) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0((strcmp(sec_hdr->type, "BTH") =3D=3D 0) &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 (priv->barker & BARKER_DNLOAD_BT_MSK))) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 *sec_addr =3D sec_hdr->target_addr;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 *sec_size =3D le32_to_cpu(sec_hdr->data_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 *p_sec =3D parser->file + parser->cur_pos;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 parser->cur_pos +=3D le32_to_cpu(sec_hdr->data_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return 1;
>
> This if statement is unreadable. This indentation gives me a headache=
=2E
>
> Also this function better return bool and not int.
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else if (strcmp(sec_hd=
r->type, "LOG") !=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_WARNING(priv, FW_DOWNLOAD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "skipping section type %s=
\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sec_hdr->type);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 parser->cur_pos +=3D le3=
2_to_cpu(sec_hdr->data_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLO=
AD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "finished with section cur_pos=3D%zd\n", parser->cur_pos);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "<--\n");
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +static int iwmct_download_section(struct iwmct_priv *priv, const u8=
 *p_sec,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t sec_size, __le32 addr)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_parser *parser =3D &priv->parser;
>> + =C2=A0 =C2=A0 struct iwmct_fw_load_hdr *hdr =3D (struct iwmct_fw_l=
oad_hdr *)parser->buf;
>> + =C2=A0 =C2=A0 const u8 *cur_block =3D p_sec;
>> + =C2=A0 =C2=A0 size_t sent =3D 0;
>> + =C2=A0 =C2=A0 int cnt =3D 0;
>> + =C2=A0 =C2=A0 int ret =3D 0;
>> + =C2=A0 =C2=A0 u32 cmd =3D 0;
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "-->\n");
>> + =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLOAD, "Download address 0x%x s=
ize 0x%zx\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr, sec_size);
>> +
>> + =C2=A0 =C2=A0 while (sent < sec_size) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int i;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 chksm =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 reset =3D atomic_rea=
d(&priv->reset);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* actual FW data */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 data_size =3D min(pa=
rser->buf_size - sizeof(*hdr),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sec_size - sent);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Pad to block size */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 trans_size =3D (data=
_size + sizeof(*hdr) +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IWMC_SDIO_BLK_SIZE - 1) &
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ~(IWMC_SDIO_BLK_SIZE - 1);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ++cnt;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* in case of reset, int=
errupt FW DOWNLAOD */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (reset) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_INFO(priv, FW_DOWNLOAD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"Reset detected. Abort FW downloa=
d!!!");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ret =3D -ECANCELED;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto exit;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(parser->buf, 0, p=
arser->buf_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd |=3D IWMC_OPCODE_WRI=
TE << CMD_HDR_OPCODE_POS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd |=3D IWMC_CMD_SIGNAT=
URE << CMD_HDR_SIGNATURE_POS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd |=3D (priv->dbg.dire=
ct ? 1 : 0) << CMD_HDR_DIRECT_ACCESS_POS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd |=3D (priv->dbg.chec=
ksum ? 1 : 0) << CMD_HDR_USE_CHECKSUM_POS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hdr->data_size =3D cpu_t=
o_le32(data_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hdr->target_addr =3D add=
r;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* checksum is allowed f=
or sizes divisible by 4 */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (data_size & 0x3)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 cmd &=3D ~CMD_HDR_USE_CHECKSUM_MSK;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(hdr->data, cur_bl=
ock, data_size);
>> +
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (cmd & CMD_HDR_USE_CH=
ECKSUM_MSK) {
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 chksm =3D data_size + le32_to_cpu(addr) + cmd;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 for (i =3D 0; i < data_size >> 2; i++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 chksm +=3D ((u32 *)cur_block)[i];
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 hdr->block_chksm =3D cpu_to_le32(chksm);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_INFO(priv, FW_DOWNLOAD, "Checksum =3D 0x%X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hdr->block_chksm);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLO=
AD, "trans#%d, len=3D%d, sent=3D%zd, "
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "sec_size=3D%zd, startAddress 0x%X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cnt, trans_size, sent, sec_size, addr);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (priv->dbg.dump)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_HEXDUMP(FW_DOWNLOAD, parser->buf, trans_size);
>> +
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hdr->cmd =3D cpu_to_le32=
(cmd);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* send it down */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* TODO: add more proper=
 sending and error checking */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D iwmct_tx(priv, 0=
, parser->buf, trans_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret !=3D 0) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_INFO(priv, FW_DOWNLOAD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "iwmct_tx returned %d\n", ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto exit;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr =3D cpu_to_le32(le3=
2_to_cpu(addr) + data_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sent +=3D data_size;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cur_block =3D p_sec + se=
nt;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (priv->dbg.blocks && =
(cnt + 1) >=3D priv->dbg.blocks) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_INFO(priv, FW_DOWNLOAD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "Block number limit is reached [%d]\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 priv->dbg.blocks);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (sent < sec_size)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;
>> +exit:
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "<--\n");
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +static int iwmct_kick_fw(struct iwmct_priv *priv, bool jump)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_parser *parser =3D &priv->parser;
>> + =C2=A0 =C2=A0 struct iwmct_fw_load_hdr *hdr =3D (struct iwmct_fw_l=
oad_hdr *)parser->buf;
>> + =C2=A0 =C2=A0 int ret;
>> + =C2=A0 =C2=A0 u32 cmd;
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "-->\n");
>> +
>> + =C2=A0 =C2=A0 memset(parser->buf, 0, parser->buf_size);
>> + =C2=A0 =C2=A0 cmd =3D IWMC_CMD_SIGNATURE << CMD_HDR_SIGNATURE_POS;
>> + =C2=A0 =C2=A0 if (jump) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd |=3D IWMC_OPCODE_JUM=
P << CMD_HDR_OPCODE_POS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hdr->target_addr =3D cpu=
_to_le32(parser->entry_point);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLO=
AD, "jump address 0x%x\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 parser->entry_point);
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd |=3D IWMC_OPCODE_LAS=
T_COMMAND << CMD_HDR_OPCODE_POS;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLO=
AD, "last command\n");
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 hdr->cmd =3D cpu_to_le32(cmd);
>> +
>> + =C2=A0 =C2=A0 LOG_HEXDUMP(FW_DOWNLOAD, parser->buf, sizeof(*hdr));
>> + =C2=A0 =C2=A0 /* send it down */
>> + =C2=A0 =C2=A0 /* TODO: add more proper sending and error checking =
*/
>> + =C2=A0 =C2=A0 ret =3D iwmct_tx(priv, 0, parser->buf, IWMC_SDIO_BLK=
_SIZE);
>> + =C2=A0 =C2=A0 if (ret)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLO=
AD, "iwmct_tx returned %d", ret);
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, INIT, "<--\n");
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +int iwmct_fw_load(struct iwmct_priv *priv)
>> +{
>> + =C2=A0 =C2=A0 const struct firmware *raw =3D NULL;
>> + =C2=A0 =C2=A0 __le32 addr;
>> + =C2=A0 =C2=A0 size_t len;
>> + =C2=A0 =C2=A0 const u8 *pdata;
>> + =C2=A0 =C2=A0 const u8 *name =3D "iwmc3200top.1.fw";
>> + =C2=A0 =C2=A0 int ret =3D 0;
>> +
>> + =C2=A0 =C2=A0 /* clear parser struct */
>> + =C2=A0 =C2=A0 memset(&priv->parser, 0, sizeof(struct iwmct_parser)=
);
>> + =C2=A0 =C2=A0 if (!name) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* get the firmware */
>> + =C2=A0 =C2=A0 ret =3D request_firmware(&raw, name, &priv->func->de=
v);
>> + =C2=A0 =C2=A0 if (ret < 0) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_DOWNL=
OAD, "%s request_firmware failed %d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 name, ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (raw->size < sizeof(struct iwmct_fw_sec_hdr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_DOWNL=
OAD, "%s smaller then (%zd) (%zd)\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 name, sizeof(struct iwmct_fw_sec_hdr), raw->size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLOAD, "Read firmware '%s'\n", =
name);
>> +
>> + =C2=A0 =C2=A0 ret =3D iwmct_fw_parser_init(priv, raw->data, raw->s=
ize, priv->trans_len);
>> + =C2=A0 =C2=A0 if (ret < 0) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_DOWNL=
OAD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 "iwmct_parser_init failed: Reason %d\n", ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* checksum =C2=A0*/
>> + =C2=A0 =C2=A0 if (!iwmct_checksum(priv)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_DOWNL=
OAD, "checksum error\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* download firmware to device */
>> + =C2=A0 =C2=A0 while (iwmct_parse_next_section(priv, &pdata, &len, =
&addr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (iwmct_download_secti=
on(priv, pdata, len, addr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_ERROR(priv, FW_DOWNLOAD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "%s download section failed\n", =
name);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ret =3D -EIO;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto exit;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 iwmct_kick_fw(priv, !!(priv->barker & BARKER_DNLOAD_=
JUMP_MSK));
>> +
>> +exit:
>> + =C2=A0 =C2=A0 kfree(priv->parser.buf);
>> +
>> + =C2=A0 =C2=A0 if (raw)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 release_firmware(raw);
>> +
>> + =C2=A0 =C2=A0 raw =3D NULL;
>> +
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> diff --git a/drivers/misc/iwmc3200top/fw-msg.h b/drivers/misc/iwmc32=
00top/fw-msg.h
>> new file mode 100644
>> index 0000000..9e26b75
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/fw-msg.h
>> @@ -0,0 +1,113 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/fw-msg.h
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#ifndef __FWMSG_H__
>> +#define __FWMSG_H__
>> +
>> +#define COMM_TYPE_D2H =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00xFF
>> +#define COMM_TYPE_H2D =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00xEE
>> +
>> +#define COMM_CATEGORY_OPERATIONAL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00x00
>> +#define COMM_CATEGORY_DEBUG =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00x01
>> +#define COMM_CATEGORY_TESTABILITY =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00x02
>> +#define COMM_CATEGORY_DIAGNOSTICS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00x03
>> +
>> +#define OP_DBG_ZSTR_MSG =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpu_to_le16(0x1A)
>> +
>> +#define FW_LOG_SRC_MAX =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 32
>> +#define FW_LOG_SRC_ALL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 255
>> +
>> +#define FW_STRING_TABLE_ADDR =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu_to_le3=
2(0x0C000000)
>> +
>> +#define CMD_DBG_LOG_LEVEL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
cpu_to_le16(0x0001)
>> +#define CMD_TST_DEV_RESET =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
cpu_to_le16(0x0060)
>> +#define CMD_TST_FUNC_RESET =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu_t=
o_le16(0x0062)
>> +#define CMD_TST_IFACE_RESET =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpu_t=
o_le16(0x0064)
>> +#define CMD_TST_CPU_UTILIZATION =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0cpu_to_le16(0x0065)
>> +#define CMD_TST_TOP_DEEP_SLEEP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 cpu_to_le16(0x0080)
>> +#define CMD_TST_WAKEUP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu_to_le16(0x0081)
>> +#define CMD_TST_FUNC_WAKEUP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpu_t=
o_le16(0x0082)
>> +#define CMD_TST_FUNC_DEEP_SLEEP_REQUEST =C2=A0 =C2=A0 =C2=A0cpu_to_=
le16(0x0083)
>> +#define CMD_TST_GET_MEM_DUMP =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu_to_le1=
6(0x0096)
>> +
>> +#define OP_OPR_ALIVE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 cpu_to_le16(0x0010)
>> +#define OP_OPR_CMD_ACK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu_to_le16(0x001F)
>> +#define OP_OPR_CMD_NACK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpu_to_le16(0x0020)
>> +#define OP_TST_MEM_DUMP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpu_to_le16(0x0043)
>> +
>> +#define CMD_FLAG_PADDING_256 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0x80
>> +
>> +#define FW_HCMD_BLOCK_SIZE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 256
>> +
>> +struct msg_hdr {
>> + =C2=A0 =C2=A0 u8 type;
>> + =C2=A0 =C2=A0 u8 category;
>> + =C2=A0 =C2=A0 __le16 opcode;
>> + =C2=A0 =C2=A0 u8 seqnum;
>> + =C2=A0 =C2=A0 u8 flags;
>> + =C2=A0 =C2=A0 __le16 length;
>> +} __attribute__((__packed__));
>> +
>> +struct log_hdr {
>> + =C2=A0 =C2=A0 __le32 timestamp;
>> + =C2=A0 =C2=A0 u8 severity;
>> + =C2=A0 =C2=A0 u8 logsource;
>> + =C2=A0 =C2=A0 __le16 reserved;
>> +} __attribute__((__packed__));
>> +
>> +struct mdump_hdr {
>> + =C2=A0 =C2=A0 u8 dmpid;
>> + =C2=A0 =C2=A0 u8 frag;
>> + =C2=A0 =C2=A0 __le16 size;
>> + =C2=A0 =C2=A0 __le32 addr;
>> +} __attribute__((__packed__));
>> +
>> +struct top_msg {
>> + =C2=A0 =C2=A0 struct msg_hdr hdr;
>> + =C2=A0 =C2=A0 union {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* D2H messages */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct log_hdr log_hdr;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 u8 data[1];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } __attribute__((__packe=
d__)) log;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct log_hdr log_hdr;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct mdump_hdr md_hdr;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 u8 data[1];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } __attribute__((__packe=
d__)) mdump;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* H2D messages */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 u8 logsource;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 u8 sevmask;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } __attribute__((__packe=
d__)) logdefs[FW_LOG_SRC_MAX];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mdump_hdr mdump_r=
eq;
>> + =C2=A0 =C2=A0 } u;
>> +} __attribute__((__packed__));
>> +
>> +
>> +#endif /* __FWMSG_H__ */
>> diff --git a/drivers/misc/iwmc3200top/iwmc3200top.h b/drivers/misc/i=
wmc3200top/iwmc3200top.h
>> new file mode 100644
>> index 0000000..59e4b7a
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/iwmc3200top.h
>> @@ -0,0 +1,202 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/iwmc3200top.h
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#ifndef __IWMC3200TOP_H__
>> +#define __IWMC3200TOP_H__
>> +
>> +#define DRV_NAME "iwmc3200top"
>> +
>> +#define IWMC_SDIO_BLK_SIZE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 256
>> +#define IWMC_DEFAULT_TR_BLK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A064
>> +#define IWMC_SDIO_DATA_ADDR =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00x0
>> +#define IWMC_SDIO_INTR_ENABLE_ADDR =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 0x14
>> +#define IWMC_SDIO_INTR_STATUS_ADDR =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 0x13
>> +#define IWMC_SDIO_INTR_CLEAR_ADDR =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00x13
>> +#define IWMC_SDIO_INTR_GET_SIZE_ADDR =C2=A0 =C2=A0 =C2=A0 =C2=A0 0x=
2C
>> +
>> +#define COMM_HUB_HEADER_LENGTH 16
>> +#define LOGGER_HEADER_LENGTH =C2=A0 10
>> +
>> +
>> +#define BARKER_DNLOAD_BT_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> +#define BARKER_DNLOAD_BT_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 BIT(BARKER=
_DNLOAD_BT_POS)
>> +#define BARKER_DNLOAD_GPS_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A01
>> +#define BARKER_DNLOAD_GPS_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0BIT(BARKER_DNLOAD_GPS_POS)
>> +#define BARKER_DNLOAD_TOP_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A02
>> +#define BARKER_DNLOAD_TOP_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0BIT(BARKER_DNLOAD_TOP_POS)
>> +#define BARKER_DNLOAD_RESERVED1_POS =C2=A03
>> +#define BARKER_DNLOAD_RESERVED1_MSK =C2=A0BIT(BARKER_DNLOAD_RESERVE=
D1_POS)
>> +#define BARKER_DNLOAD_JUMP_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 4
>> +#define BARKER_DNLOAD_JUMP_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 BIT(BARKER_DNLOAD_JUMP_POS)
>> +#define BARKER_DNLOAD_SYNC_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 5
>> +#define BARKER_DNLOAD_SYNC_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 BIT(BARKER_DNLOAD_SYNC_POS)
>> +#define BARKER_DNLOAD_RESERVED2_POS =C2=A06
>> +#define BARKER_DNLOAD_RESERVED2_MSK =C2=A0(0x3 << BARKER_DNLOAD_RES=
ERVED2_POS)
>> +#define BARKER_DNLOAD_BARKER_POS =C2=A0 =C2=A0 8
>> +#define BARKER_DNLOAD_BARKER_MSK =C2=A0 =C2=A0 (0xffffff << BARKER_=
DNLOAD_BARKER_POS)
>> +
>> +#define IWMC_BARKER_REBOOT =C2=A0 (0xdeadbe << BARKER_DNLOAD_BARKER=
_POS)
>> +/* whole field barker */
>> +#define IWMC_BARKER_ACK =C2=A0 =C2=A0 =C2=A00xfeedbabe
>> +
>> +#define IWMC_CMD_SIGNATURE =C2=A0 0xcbbc
>> +
>> +#define CMD_HDR_OPCODE_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> +#define CMD_HDR_OPCODE_MSK_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 (0xf << CMD_HDR_OPCODE_MSK_POS)
>> +#define CMD_HDR_RESPONSE_CODE_POS =C2=A0 =C2=A04
>> +#define CMD_HDR_RESPONSE_CODE_MSK =C2=A0 =C2=A0(0xf << CMD_HDR_RESP=
ONSE_CODE_POS)
>> +#define CMD_HDR_USE_CHECKSUM_POS =C2=A0 =C2=A0 8
>> +#define CMD_HDR_USE_CHECKSUM_MSK =C2=A0 =C2=A0 BIT(CMD_HDR_USE_CHEC=
KSUM_POS)
>> +#define CMD_HDR_RESPONSE_REQUIRED_POS =C2=A0 =C2=A0 =C2=A0 =C2=A09
>> +#define CMD_HDR_RESPONSE_REQUIRED_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0BI=
T(CMD_HDR_RESPONSE_REQUIRED_POS)
>> +#define CMD_HDR_DIRECT_ACCESS_POS =C2=A0 =C2=A010
>> +#define CMD_HDR_DIRECT_ACCESS_MSK =C2=A0 =C2=A0BIT(CMD_HDR_DIRECT_A=
CCESS_POS)
>> +#define CMD_HDR_RESERVED_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 11
>> +#define CMD_HDR_RESERVED_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 BIT(0x1f <=
< CMD_HDR_RESERVED_POS)
>> +#define CMD_HDR_SIGNATURE_POS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A016
>> +#define CMD_HDR_SIGNATURE_MSK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0BIT(0xffff << CMD_HDR_SIGNATURE_POS)
>> +
>> +enum {
>> + =C2=A0 =C2=A0 IWMC_OPCODE_PING =3D 0,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_READ =3D 1,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_WRITE =3D 2,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_JUMP =3D 3,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_REBOOT =3D 4,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_PERSISTENT_WRITE =3D 5,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_PERSISTENT_READ =3D 6,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_READ_MODIFY_WRITE =3D 7,
>> + =C2=A0 =C2=A0 IWMC_OPCODE_LAST_COMMAND =3D 15
>> +};
>> +
>> +struct iwmct_fw_load_hdr {
>> + =C2=A0 =C2=A0 __le32 cmd;
>> + =C2=A0 =C2=A0 __le32 target_addr;
>> + =C2=A0 =C2=A0 __le32 data_size;
>> + =C2=A0 =C2=A0 __le32 block_chksm;
>> + =C2=A0 =C2=A0 u8 data[0];
>> +};
>> +
>> +/**
>> + * struct iwmct_fw_hdr
>> + * holds all sw components versions
>> + */
>> +struct iwmct_fw_hdr {
>> + =C2=A0 =C2=A0 u8 top_major;
>> + =C2=A0 =C2=A0 u8 top_minor;
>> + =C2=A0 =C2=A0 u8 top_revision;
>> + =C2=A0 =C2=A0 u8 gps_major;
>> + =C2=A0 =C2=A0 u8 gps_minor;
>> + =C2=A0 =C2=A0 u8 gps_revision;
>> + =C2=A0 =C2=A0 u8 bt_major;
>> + =C2=A0 =C2=A0 u8 bt_minor;
>> + =C2=A0 =C2=A0 u8 bt_revision;
>> + =C2=A0 =C2=A0 u8 tic_name[31];
>> +};
>> +
>> +/**
>> + * struct iwmct_fw_sec_hdr
>> + * @type: function type
>> + * @data_size: section's data size
>> + * @target_addr: download address
>> + */
>> +struct iwmct_fw_sec_hdr {
>> + =C2=A0 =C2=A0 u8 type[4];
>> + =C2=A0 =C2=A0 __le32 data_size;
>> + =C2=A0 =C2=A0 __le32 target_addr;
>> +};
>> +
>> +/**
>> + * struct iwmct_parser
>> + * @file: fw image
>> + * @file_size: fw size
>> + * @cur_pos: position in file
>> + * @buf: temp buf for download
>> + * @buf_size: size of buf
>> + * @entry_point: address to jump in fw kick-off
>> + */
>> +struct iwmct_parser {
>> + =C2=A0 =C2=A0 const u8 *file;
>> + =C2=A0 =C2=A0 size_t file_size;
>> + =C2=A0 =C2=A0 size_t cur_pos;
>> + =C2=A0 =C2=A0 u8 *buf;
>> + =C2=A0 =C2=A0 size_t buf_size;
>> + =C2=A0 =C2=A0 u32 entry_point;
>> + =C2=A0 =C2=A0 struct iwmct_fw_hdr versions;
>> +};
>> +
>> +
>> +struct iwmct_work_struct {
>> + =C2=A0 =C2=A0 struct list_head list;
>> + =C2=A0 =C2=A0 ssize_t iosize;
>> +};
>> +
>> +struct iwmct_dbg {
>> + =C2=A0 =C2=A0 int blocks;
>> + =C2=A0 =C2=A0 bool dump;
>> + =C2=A0 =C2=A0 bool jump;
>> + =C2=A0 =C2=A0 bool direct;
>> + =C2=A0 =C2=A0 bool checksum;
>> + =C2=A0 =C2=A0 bool fw_download;
>> + =C2=A0 =C2=A0 int block_size;
>> + =C2=A0 =C2=A0 int download_trans_blks;
>> +
>> + =C2=A0 =C2=A0 char label_fw[256];
>> +};
>> +
>> +struct iwmct_priv {
>> + =C2=A0 =C2=A0 struct sdio_func *func;
>> + =C2=A0 =C2=A0 struct iwmct_debugfs *dbgfs;
>> + =C2=A0 =C2=A0 struct iwmct_parser parser;
>> + =C2=A0 =C2=A0 atomic_t reset;
>> + =C2=A0 =C2=A0 atomic_t dev_sync;
>> + =C2=A0 =C2=A0 u32 trans_len;
>> + =C2=A0 =C2=A0 u32 barker;
>> + =C2=A0 =C2=A0 struct iwmct_dbg dbg;
>> +
>> + =C2=A0 =C2=A0 /* drivers work queue */
>> + =C2=A0 =C2=A0 struct workqueue_struct *wq;
>> + =C2=A0 =C2=A0 struct workqueue_struct *bus_rescan_wq;
>> + =C2=A0 =C2=A0 struct work_struct bus_rescan_worker;
>> + =C2=A0 =C2=A0 struct work_struct isr_worker;
>> +
>> + =C2=A0 =C2=A0 /* drivers wait queue */
>> + =C2=A0 =C2=A0 wait_queue_head_t wait_q;
>> +
>> + =C2=A0 =C2=A0 /* rx request list */
>> + =C2=A0 =C2=A0 struct list_head read_req_list;
>> +};
>> +
>> +extern int iwmct_tx(struct iwmct_priv *priv, unsigned int addr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *src, int count);
>> +
>> +extern int iwmct_fw_load(struct iwmct_priv *priv);
>> +
>> +extern void iwmct_dbg_init_params(struct iwmct_priv *drv);
>> +extern void iwmct_dbg_init_drv_attrs(struct device_driver *drv);
>> +extern void iwmct_dbg_remove_drv_attrs(struct device_driver *drv);
>> +extern int iwmct_send_hcmd(struct iwmct_priv *priv, u8 *cmd, u16 le=
n);
>> +
>> +#endif =C2=A0/* =C2=A0__IWMC3200TOP_H__ =C2=A0*/
>> diff --git a/drivers/misc/iwmc3200top/log.c b/drivers/misc/iwmc3200t=
op/log.c
>> new file mode 100644
>> index 0000000..96b5e4a
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/log.c
>> @@ -0,0 +1,339 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/log.c
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/mmc/sdio_func.h>
>> +#include <linux/ctype.h>
>> +#include "fw-msg.h"
>> +#include "iwmc3200top.h"
>> +#include "log.h"
>> +
>> +/* Maximal hexadecimal string size of the FW memdump message */
>> +#define LOG_MSG_SIZE_MAX =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
12400
>> +
>> +/* iwmct_logdefs is a global used by log macros */
>> +u8 iwmct_logdefs[LOG_SRC_MAX];
>> +static u8 iwmct_fw_logdefs[FW_LOG_SRC_MAX];
>> +
>> +
>> +static int _log_set_log_filter(u8 *logdefs, int size, u8 src, u8 lo=
gmask)
>> +{
>> + =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 if (src < size)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 logdefs[src] =3D logmask=
;
>> + =C2=A0 =C2=A0 else if (src =3D=3D LOG_SRC_ALL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < size; =
i++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 logdefs[i] =3D logmask;
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -1;
>> +
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +
>> +int iwmct_log_set_filter(u8 src, u8 logmask)
>> +{
>> + =C2=A0 =C2=A0 return _log_set_log_filter(iwmct_logdefs, LOG_SRC_MA=
X, src, logmask);
>> +}
>> +
>> +
>> +int iwmct_log_set_fw_filter(u8 src, u8 logmask)
>> +{
>> + =C2=A0 =C2=A0 return _log_set_log_filter(iwmct_fw_logdefs,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0FW_LOG_SRC_MAX, src, logma=
sk);
>> +}
>> +
>> +
>> +static int log_msg_format_hex(char *str, int slen, u8 *ibuf,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 int ilen, char *pref)
>> +{
>> + =C2=A0 =C2=A0 int pos =3D 0;
>> + =C2=A0 =C2=A0 int i;
>> + =C2=A0 =C2=A0 int len;
>> +
>> + =C2=A0 =C2=A0 for (pos =3D 0, i =3D 0; pos < slen - 2 && pref[i] !=
=3D '\0'; i++, pos++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 str[pos] =3D pref[i];
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; pos < slen - 2 && i < ilen; pos +=3D l=
en, i++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 len =3D snprintf(&str[po=
s], slen - pos - 1, " %2.2X", ibuf[i]);
>> +
>> + =C2=A0 =C2=A0 if (i < ilen)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -1;
>> +
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +/* =C2=A0 NOTE: This function is not thread safe.
>> + =C2=A0 =C2=A0 Currently it's called only from sdio rx worker - no =
race there
>> +*/
>> +void iwmct_log_top_message(struct iwmct_priv *priv, u8 *buf, int le=
n)
>> +{
>> + =C2=A0 =C2=A0 struct top_msg *msg;
>> + =C2=A0 =C2=A0 static char logbuf[LOG_MSG_SIZE_MAX];
>> +
>> + =C2=A0 =C2=A0 msg =3D (struct top_msg *)buf;
>> +
>> + =C2=A0 =C2=A0 if (len < sizeof(msg->hdr) + sizeof(msg->u.log.log_h=
dr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_MSG, =
"Log message from TOP "
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 "is too short %d (expected %zd)\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 len, sizeof(msg->hdr) + sizeof(msg->u.log.log_hdr));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (!(iwmct_fw_logdefs[msg->u.log.log_hdr.logsource]=
 &
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BIT(msg->u.log.log_hdr.s=
everity)) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(iwmct_logdefs[LOG_SRC_FW_MSG] & BIT(=
msg->u.log.log_hdr.severity)))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> + =C2=A0 =C2=A0 switch (msg->hdr.category) {
>> + =C2=A0 =C2=A0 case COMM_CATEGORY_TESTABILITY:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(iwmct_logdefs[LOG_=
SRC_TST] &
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BIT=
(msg->u.log.log_hdr.severity)))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (log_msg_format_hex(l=
ogbuf, LOG_MSG_SIZE_MAX, buf,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0le16_to_cpu(=
msg->hdr.length) +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sizeof(msg->=
hdr), "<TST>"))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_WARNING(priv, TST,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "TOP TST message is too long, tr=
uncating...");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_WARNING(priv, TST, "=
%s\n", logbuf);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 case COMM_CATEGORY_DEBUG:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (msg->hdr.opcode =3D=3D=
 OP_DBG_ZSTR_MSG)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_INFO(priv, FW_MSG, "%s %s", "<DBG>",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0((u8 *)msg) =
+ sizeof(msg->hdr)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + sizeof(ms=
g->u.log.log_hdr));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (log_msg_format_hex(logbuf, LOG_MSG_SIZE_MAX, buf,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 le16_to_cpu=
(msg->hdr.length)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 + sizeof(msg->hdr),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "<DBG>"))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_WARNING(priv, FW_MSG,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "TOP DBG me=
ssage is too long,"
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "truncating=
=2E..");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_WARNING(priv, FW_MSG, "%s\n", logbuf);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 default:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 }
>> +}
>> +
>> +static int _log_get_filter_str(u8 *logdefs, int logdefsz, char *buf=
, int size)
>> +{
>> + =C2=A0 =C2=A0 int i, pos, len;
>> + =C2=A0 =C2=A0 for (i =3D 0, pos =3D 0; (pos < size-1) && (i < logd=
efsz); i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 len =3D snprintf(&buf[po=
s], size - pos - 1, "0x%02X%02X,",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 i, logdefs[i]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pos +=3D len;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 buf[pos-1] =3D '\n';
>> + =C2=A0 =C2=A0 buf[pos] =3D '\0';
>> +
>> + =C2=A0 =C2=A0 if (i < logdefsz)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -1;
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +int log_get_filter_str(char *buf, int size)
>> +{
>> + =C2=A0 =C2=A0 return _log_get_filter_str(iwmct_logdefs, LOG_SRC_MA=
X, buf, size);
>> +}
>> +
>> +int log_get_fw_filter_str(char *buf, int size)
>> +{
>> + =C2=A0 =C2=A0 return _log_get_filter_str(iwmct_fw_logdefs, FW_LOG_=
SRC_MAX, buf, size);
>> +}
>> +
>> +#define HEXADECIMAL_RADIX =C2=A0 =C2=A016
>> +#define LOG_SRC_FORMAT =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 7 /* log level is in format of "0xXXXX," */
>> +
>> +ssize_t show_iwmct_log_level(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct device_attribute *attr, char *bu=
f)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv =3D d->driver_data;
>> + =C2=A0 =C2=A0 char *str_buf;
>> + =C2=A0 =C2=A0 int buf_size;
>> + =C2=A0 =C2=A0 ssize_t ret =3D -EAGAIN;
>> +
>> + =C2=A0 =C2=A0 buf_size =3D (LOG_SRC_FORMAT * LOG_SRC_MAX) + 1;
>> + =C2=A0 =C2=A0 str_buf =3D kzalloc(buf_size, GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!str_buf) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, DEBUGFS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "failed to allocate %d bytes\n", buf_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (log_get_filter_str(str_buf, buf_size) < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> +
>> + =C2=A0 =C2=A0 ret =3D sprintf(buf, "%s", str_buf);
>> +
>> +exit:
>> + =C2=A0 =C2=A0 kfree(str_buf);
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +ssize_t store_iwmct_log_level(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct device_attribute *attr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 const char *buf, size_t count)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv =3D d->driver_data;
>> + =C2=A0 =C2=A0 char *token, *str_buf =3D NULL;
>> + =C2=A0 =C2=A0 long val;
>> + =C2=A0 =C2=A0 u8 src, mask;
>> +
>> + =C2=A0 =C2=A0 if (!count)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
>> +
>> + =C2=A0 =C2=A0 str_buf =3D kzalloc(count, GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!str_buf) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, DEBUGFS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "failed to allocate %zd bytes\n", count);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 memcpy(str_buf, buf, count);
>> +
>> + =C2=A0 =C2=A0 while ((token =3D strsep(&str_buf, ",")) !=3D NULL) =
{
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (isspace(*token))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ++token;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (strict_strtol(token,=
 HEXADECIMAL_RADIX, &val)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_ERROR(priv, DEBUGFS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "failed to convert string to lon=
g %s\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 token);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto err;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mask =C2=A0=3D val & 0xF=
=46;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 src =3D (val & 0XFF00) >=
> 8;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iwmct_log_set_filter(src=
, mask);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 kfree(str_buf);
>> + =C2=A0 =C2=A0 return count;
>> +
>> +err:
>> + =C2=A0 =C2=A0 kfree(str_buf);
>> + =C2=A0 =C2=A0 return -EAGAIN;
>> +}
>> +
>> +ssize_t show_iwmct_log_level_fw(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct device_attribute *attr, char *buf)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv =3D d->driver_data;
>> + =C2=A0 =C2=A0 char *str_buf;
>> + =C2=A0 =C2=A0 int buf_size;
>> + =C2=A0 =C2=A0 ssize_t ret =3D -EAGAIN;
>> +
>> + =C2=A0 =C2=A0 buf_size =3D (LOG_SRC_FORMAT * FW_LOG_SRC_MAX) + 2;
>> +
>> + =C2=A0 =C2=A0 str_buf =3D kzalloc(buf_size, GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!str_buf) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, DEBUGFS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "failed to allocate %d bytes\n", buf_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (log_get_fw_filter_str(str_buf, buf_size) < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> +
>> + =C2=A0 =C2=A0 ret =3D sprintf(buf, "%s", str_buf);
>> +
>> +exit:
>> + =C2=A0 =C2=A0 kfree(str_buf);
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +ssize_t store_iwmct_log_level_fw(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct device_attribute *attr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 const char *buf, size_t count)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv =3D d->driver_data;
>> + =C2=A0 =C2=A0 char *token, *str_buf =3D NULL;
>> + =C2=A0 =C2=A0 long val;
>> + =C2=A0 =C2=A0 u8 src, mask;
>> + =C2=A0 =C2=A0 struct top_msg cmd;
>> + =C2=A0 =C2=A0 u16 cmdlen =3D 0;
>> + =C2=A0 =C2=A0 int i, rc;
>> +
>> + =C2=A0 =C2=A0 if (!count)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
>> +
>> + =C2=A0 =C2=A0 str_buf =3D kzalloc(count, GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!str_buf) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, DEBUGFS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "failed to allocate %zd bytes\n", count);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 memcpy(str_buf, buf, count);
>> +
>> + =C2=A0 =C2=A0 cmd.hdr.type =3D COMM_TYPE_H2D;
>> + =C2=A0 =C2=A0 cmd.hdr.category =3D COMM_CATEGORY_DEBUG;
>> + =C2=A0 =C2=A0 cmd.hdr.opcode =3D CMD_DBG_LOG_LEVEL;
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; ((token =3D strsep(&str_buf, ",")) !=3D=
 NULL) &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(i <=
 FW_LOG_SRC_MAX); i++) {
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (isspace(*token))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ++token;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (strict_strtol(token,=
 HEXADECIMAL_RADIX, &val)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_ERROR(priv, DEBUGFS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "failed to convert string to lon=
g %s\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 token);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto err;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mask =C2=A0=3D val & 0xF=
=46; /* LSB */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 src =3D (val & 0XFF00) >=
> 8; /* 2nd least significant byte. */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iwmct_log_set_fw_filter(=
src, mask);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd.u.logdefs[i].logsour=
ce =3D src;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmd.u.logdefs[i].sevmask=
 =3D mask;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 cmd.hdr.length =3D cpu_to_le16(i * sizeof(cmd.u.logd=
efs[0]));
>> + =C2=A0 =C2=A0 cmdlen =3D (i * sizeof(cmd.u.logdefs[0]) + sizeof(cm=
d.hdr));
>> +
>> + =C2=A0 =C2=A0 rc =3D iwmct_send_hcmd(priv, (u8 *) &cmd, cmdlen);
>> + =C2=A0 =C2=A0 if (rc) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, DEBUGFS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 "Failed to send %d bytes of fwcmd, rc=3D%d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 cmdlen, rc);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
>> + =C2=A0 =C2=A0 } else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, DEBUGFS, =
"fwcmd sent (%d bytes)\n", cmdlen);
>> +
>> + =C2=A0 =C2=A0 kfree(str_buf);
>> + =C2=A0 =C2=A0 return count;
>> +
>> +err:
>> + =C2=A0 =C2=A0 kfree(str_buf);
>> + =C2=A0 =C2=A0 return -EAGAIN;
>> +}
>> +
>> diff --git a/drivers/misc/iwmc3200top/log.h b/drivers/misc/iwmc3200t=
op/log.h
>> new file mode 100644
>> index 0000000..aba8121
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/log.h
>> @@ -0,0 +1,158 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/log.h
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#ifndef __LOG_H__
>> +#define __LOG_H__
>> +
>> +
>> +/* log severity:
>> + * The log levels here match FW log levels
>> + * so values need to stay as is */
>> +#define LOG_SEV_CRITICAL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0
>> +#define LOG_SEV_ERROR =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01
>> +#define LOG_SEV_WARNING =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02
>> +#define LOG_SEV_INFO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 3
>> +#define LOG_SEV_INFOEX =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4
>> +
>> +#define LOG_SEV_FILTER_ALL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 (BIT(LOG_SEV_CRITICAL) | =C2=A0 =C2=A0 =C2=A0 =C2=A0=
\
>> + =C2=A0 =C2=A0 =C2=A0BIT(LOG_SEV_ERROR) =C2=A0 =C2=A0| =C2=A0 =C2=A0=
 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0BIT(LOG_SEV_WARNING) =C2=A0| =C2=A0 =C2=A0 =C2=
=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0BIT(LOG_SEV_INFO) =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0BIT(LOG_SEV_INFOEX))
>> +
>> +/* log source */
>> +#define LOG_SRC_INIT =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 0
>> +#define LOG_SRC_DEBUGFS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01
>> +#define LOG_SRC_FW_DOWNLOAD =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02
>> +#define LOG_SRC_FW_MSG =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 3
>> +#define LOG_SRC_TST =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A04
>> +#define LOG_SRC_IRQ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A05
>> +
>> +#define =C2=A0 =C2=A0 =C2=A0LOG_SRC_MAX =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 6
>> +#define =C2=A0 =C2=A0 =C2=A0LOG_SRC_ALL =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0xFF
>> +
>> +/**
>> + * Default intitialization runtime log level
>> + */
>> +#ifndef LOG_SEV_FILTER_RUNTIME
>> +#define LOG_SEV_FILTER_RUNTIME =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 (BIT(LOG_SEV_CRITICAL) =C2=A0| =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0BIT(LOG_SEV_ERROR) =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0BIT(LOG_SEV_WARNING))
>> +#endif
>> +
>> +#ifndef FW_LOG_SEV_FILTER_RUNTIME
>> +#define FW_LOG_SEV_FILTER_RUNTIME =C2=A0 =C2=A0LOG_SEV_FILTER_ALL
>> +#endif
>> +
>> +#ifdef CONFIG_IWMC3200TOP_DEBUG
>> +/**
>> + * Log macros
>> + */
>> +
>> +#define priv2dev(priv) (&(priv->func)->dev)
>> +
>> +#define LOG_CRITICAL(priv, src, fmt, args...) =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0\
>> +do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_CRI=
TICAL)) =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_crit(priv2dev(priv),=
 "%s %d: " fmt, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 __func__, __LINE__, ##args); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> +} while (0)
>> +
>> +#define LOG_ERROR(priv, src, fmt, args...) =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> +do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_ERR=
OR)) =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(priv2dev(priv), =
"%s %d: " fmt, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 __func__, __LINE__, ##args); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> +} while (0)
>> +
>> +#define LOG_WARNING(priv, src, fmt, args...) =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> +do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_WAR=
NING)) =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_warn(priv2dev(priv),=
 "%s %d: " fmt, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__func__, __LINE__, ##args); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> +} while (0)
>> +
>> +#define LOG_INFO(priv, src, fmt, args...) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> +do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INF=
O)) =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_info(priv2dev(priv),=
 "%s %d: " fmt, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__func__, __LINE__, ##args); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> +} while (0)
>> +
>> +#define LOG_INFOEX(priv, src, fmt, args...) =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> +do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INF=
OEX)) =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_dbg(priv2dev(priv), =
"%s %d: " fmt, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__func__, __LINE__, ##args); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>> +} while (0)
>> +
>> +#define LOG_HEXDUMP(src, ptr, len) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 \
>> +do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INF=
OEX)) =C2=A0 =C2=A0 =C2=A0 \
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 print_hex_dump(KERN_DEBU=
G, "", DUMP_PREFIX_NONE, =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 16, 1, ptr, len, false); =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> +} while (0)
>> +
>> +void iwmct_log_top_message(struct iwmct_priv *priv, u8 *buf, int le=
n);
>> +
>> +extern u8 iwmct_logdefs[];
>> +
>> +int iwmct_log_set_filter(u8 src, u8 logmask);
>> +int iwmct_log_set_fw_filter(u8 src, u8 logmask);
>> +
>> +ssize_t show_iwmct_log_level(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct device_attribute *attr, char *buf);
>> +ssize_t store_iwmct_log_level(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct device_attribute *attr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 const char *buf, size_t count);
>> +ssize_t show_iwmct_log_level_fw(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct device_attribute *attr, char *buf);
>> +ssize_t store_iwmct_log_level_fw(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct device_attribute *attr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 const char *buf, size_t count);
>> +
>> +#else
>> +
>> +#define LOG_CRITICAL(priv, src, fmt, args...)
>> +#define LOG_ERROR(priv, src, fmt, args...)
>> +#define LOG_WARNING(priv, src, fmt, args...)
>> +#define LOG_INFO(priv, src, fmt, args...)
>> +#define LOG_INFOEX(priv, src, fmt, args...)
>> +#define LOG_HEXDUMP(src, ptr, len)
>> +
>> +static inline void iwmct_log_top_message(struct iwmct_priv *priv,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 *b=
uf, int len) {}
>> +static inline int iwmct_log_set_filter(u8 src, u8 logmask) { return=
 0; }
>> +static inline int iwmct_log_set_fw_filter(u8 src, u8 logmask) { ret=
urn 0; }
>> +
>> +#endif /* CONFIG_IWMC3200TOP_DEBUG */
>> +
>> +int log_get_filter_str(char *buf, int size);
>> +int log_get_fw_filter_str(char *buf, int size);
>> +
>> +#endif /* __LOG_H__ */
>
> Seriously. Please just use dynamic_printk and lets remove all this lo=
g
> infrastructure. It is way too much overhead for too little benefit.
>
>> diff --git a/drivers/misc/iwmc3200top/main.c b/drivers/misc/iwmc3200=
top/main.c
>> new file mode 100644
>> index 0000000..09f8d06
>> --- /dev/null
>> +++ b/drivers/misc/iwmc3200top/main.c
>> @@ -0,0 +1,702 @@
>> +/*
>> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
>> + * drivers/misc/iwmc3200top/main.c
>> + *
>> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License vers=
ion
>> + * 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
>> + * 02110-1301, USA.
>> + *
>> + *
>> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> + * =C2=A0-
>> + *
>> + */
>> +
>> +#include <linux/module.h>
>> +#include <linux/init.h>
>> +#include <linux/kernel.h>
>> +#include <linux/mmc/sdio_ids.h>
>> +#include <linux/mmc/sdio_func.h>
>> +#include <linux/mmc/sdio.h>
>> +
>> +#include "iwmc3200top.h"
>> +#include "log.h"
>> +#include "fw-msg.h"
>> +#include "debugfs.h"
>> +
>> +
>> +#define DRIVER_DESCRIPTION "Intel(R) IWMC 3200 Top Driver"
>> +#define DRIVER_COPYRIGHT "Copyright (c) 2008 Intel Corporation."
>> +
>> +#define IWMCT_VERSION "0.1.62"
>> +
>> +#ifdef REPOSITORY_LABEL
>> +#define RL REPOSITORY_LABEL
>> +#else
>> +#define RL ""
>> +#endif
>> +
>> +#ifdef CONFIG_IWMC3200TOP_DEBUG
>> +#define VD "-d"
>> +#else
>> +#define VD
>> +#endif
>> +
>> +#define DRIVER_VERSION IWMCT_VERSION "-" =C2=A0__stringify(RL) VD
>> +
>> +MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
>> +MODULE_VERSION(DRIVER_VERSION);
>> +MODULE_LICENSE("GPL");
>> +MODULE_AUTHOR(DRIVER_COPYRIGHT);
>> +
>> +
>> +#ifndef SDIO_DEVICE_ID_INTEL_IWMC3200TOP
>> +#define SDIO_DEVICE_ID_INTEL_IWMC3200TOP =C2=A0 =C2=A0 0x1404
>> +#endif
>> +
>> +/*
>> + * This workers main task is to wait for OP_OPR_ALIVE
>> + * from TOP FW until ALIVE_MSG_TIMOUT timeout is elapsed.
>> + * When OP_OPR_ALIVE received it will issue
>> + * a call to "bus_rescan_devices".
>> + */
>> +static void iwmct_rescan_worker(struct work_struct *ws)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv;
>> + =C2=A0 =C2=A0 int ret;
>> +
>> + =C2=A0 =C2=A0 priv =3D container_of(ws, struct iwmct_priv, bus_res=
can_worker);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, FW_MSG, "Calling bus_rescan\n");
>> +
>> + =C2=A0 =C2=A0 ret =3D bus_rescan_devices(priv->func->dev.bus);
>> + =C2=A0 =C2=A0 if (ret < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_DOWNLO=
AD, "bus_rescan_devices FAILED!!!\n");
>> +}
>> +
>> +static void op_top_message(struct iwmct_priv *priv, struct top_msg =
*msg)
>> +{
>> + =C2=A0 =C2=A0 switch (msg->hdr.opcode) {
>> + =C2=A0 =C2=A0 case OP_OPR_ALIVE:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_MSG, "=
Got ALIVE from device, wake rescan\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 queue_work(priv->bus_res=
can_wq, &priv->bus_rescan_worker);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 default:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, FW_MSG, "=
Received msg opcode 0x%X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 msg->hdr.opcode);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 }
>> +}
>> +
>> +
>> +static void handle_top_message(struct iwmct_priv *priv, u8 *buf, in=
t len)
>> +{
>> + =C2=A0 =C2=A0 struct top_msg *msg;
>> +
>> + =C2=A0 =C2=A0 msg =3D (struct top_msg *)buf;
>> +
>> + =C2=A0 =C2=A0 if (msg->hdr.type !=3D COMM_TYPE_D2H) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_MSG,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "Message from TOP with invalid message type 0x%X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 msg->hdr.type);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (len < sizeof(msg->hdr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_MSG,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "Message from TOP is too short for message header "
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "received %d bytes, expected at least %zd bytes\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 len, sizeof(msg->hdr));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (len < le16_to_cpu(msg->hdr.length) + sizeof(msg-=
>hdr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_MSG,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "Message length (%d bytes) is shorter than "
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "in header (%d bytes)\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 len, le16_to_cpu(msg->hdr.length));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 switch (msg->hdr.category) {
>> + =C2=A0 =C2=A0 case COMM_CATEGORY_OPERATIONAL:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 op_top_message(priv, (st=
ruct top_msg *)buf);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> +
>> + =C2=A0 =C2=A0 case COMM_CATEGORY_DEBUG:
>> + =C2=A0 =C2=A0 case COMM_CATEGORY_TESTABILITY:
>> + =C2=A0 =C2=A0 case COMM_CATEGORY_DIAGNOSTICS:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iwmct_log_top_message(pr=
iv, buf, len);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> +
>> + =C2=A0 =C2=A0 default:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_MSG,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "Message from TOP with unknown category 0x%X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 msg->hdr.category);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 }
>> +}
>> +
>> +int iwmct_send_hcmd(struct iwmct_priv *priv, u8 *cmd, u16 len)
>> +{
>> + =C2=A0 =C2=A0 int ret;
>> + =C2=A0 =C2=A0 u8 *buf;
>> +
>> + =C2=A0 =C2=A0 LOG_INFOEX(priv, FW_MSG, "Sending hcmd:\n");
>> +
>> + =C2=A0 =C2=A0 /* add padding to 256 for IWMC */
>> + =C2=A0 =C2=A0 ((struct top_msg *)cmd)->hdr.flags |=3D CMD_FLAG_PAD=
DING_256;
>> +
>> + =C2=A0 =C2=A0 LOG_HEXDUMP(FW_MSG, cmd, len);
>> +
>> + =C2=A0 =C2=A0 if (len > FW_HCMD_BLOCK_SIZE) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_MSG, =
"size %d exceeded hcmd max size %d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 len, FW_HCMD_BLOCK_SIZE);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -1;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 buf =3D kzalloc(FW_HCMD_BLOCK_SIZE, GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!buf) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, FW_MSG, =
"kzalloc error, buf size %d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 FW_HCMD_BLOCK_SIZE);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -1;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 memcpy(buf, cmd, len);
>> +
>> + =C2=A0 =C2=A0 sdio_claim_host(priv->func);
>> + =C2=A0 =C2=A0 ret =3D sdio_memcpy_toio(priv->func, IWMC_SDIO_DATA_=
ADDR, buf,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0FW_HCMD_BLOCK_SIZE);
>> + =C2=A0 =C2=A0 sdio_release_host(priv->func);
>> +
>> + =C2=A0 =C2=A0 kfree(buf);
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +int iwmct_tx(struct iwmct_priv *priv, unsigned int addr,
>> + =C2=A0 =C2=A0 void *src, int count)
>> +{
>> + =C2=A0 =C2=A0 int ret;
>> +
>> + =C2=A0 =C2=A0 sdio_claim_host(priv->func);
>> + =C2=A0 =C2=A0 ret =3D sdio_memcpy_toio(priv->func, addr, src, coun=
t);
>> + =C2=A0 =C2=A0 sdio_release_host(priv->func);
>> +
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +static void iwmct_irq_read_worker(struct work_struct *ws)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv;
>> + =C2=A0 =C2=A0 struct iwmct_work_struct *read_req;
>> + =C2=A0 =C2=A0 __le32 *buf =3D NULL;
>> + =C2=A0 =C2=A0 int ret, val, i;
>> + =C2=A0 =C2=A0 int iosize;
>> + =C2=A0 =C2=A0 u32 barker;
>> +
>> + =C2=A0 =C2=A0 priv =3D container_of(ws, struct iwmct_priv, isr_wor=
ker);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "enter iwmct_irq_read_worker %p\=
n", ws);
>> +
>> + =C2=A0 =C2=A0 /* --------------------- Handshake with device -----=
--------------- */
>> + =C2=A0 =C2=A0 sdio_claim_host(priv->func);
>> +
>> + =C2=A0 =C2=A0 /* all list manipulations have to be protected by
>> + =C2=A0 =C2=A0 =C2=A0* sdio_claim_host/sdio_release_host */
>> + =C2=A0 =C2=A0 if (list_empty(&priv->read_req_list)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ, "re=
ad_req_list empty in read worker\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit_release;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 read_req =3D list_entry(priv->read_req_list.next,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 struct iwmct_work_struct, list);
>> +
>> + =C2=A0 =C2=A0 list_del(&read_req->list);
>> + =C2=A0 =C2=A0 iosize =3D read_req->iosize;
>> + =C2=A0 =C2=A0 kfree(read_req);
>> +
>> + =C2=A0 =C2=A0 buf =3D kzalloc(iosize, GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!buf) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ, "kz=
alloc error, buf size %d\n", iosize);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit_release;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "iosize=3D%d, buf=3D%p, func=3D%=
d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iosize, buf, priv->func->num);
>> +
>> + =C2=A0 =C2=A0 /* read from device */
>> + =C2=A0 =C2=A0 ret =3D sdio_memcpy_fromio(priv->func, buf, IWMC_SDI=
O_DATA_ADDR, iosize);
>> + =C2=A0 =C2=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ, "er=
ror %d reading buffer\n", ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit_release;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 LOG_HEXDUMP(IRQ, (u8 *)buf, iosize);
>> +
>> + =C2=A0 =C2=A0 barker =3D le32_to_cpu(buf[0]);
>> + =C2=A0 =C2=A0 if (barker !=3D IWMC_BARKER_ACK &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0(barker & BARKER_DNLOAD_BARKER_MSK) !=3D=
 IWMC_BARKER_REBOOT) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Handle Top Commhub me=
ssage.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Current handling=
 - treat all message as
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* logger messages =
and print the context as a string. */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sdio_release_host(priv->=
func);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 handle_top_message(priv,=
 (u8 *)buf, iosize);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* verify basic barker sanity */
>> + =C2=A0 =C2=A0 for (i =3D 1; i < 4; i++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (buf[i] !=3D buf[0]) =
{
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_ERROR(priv, IRQ, "Corrupted barker,"
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0"buf[%d]=3D%x buf[0]=3D%x\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0i, buf[i], buf[0]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto exit_release;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 val =3D atomic_read(&priv->dev_sync);
>> +
>> + =C2=A0 =C2=A0 switch (val) {
>> + =C2=A0 =C2=A0 case 0:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* we expect to recieve =
REBOOT BARKER */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((barker & BARKER_DNL=
OAD_BARKER_MSK) !=3D IWMC_BARKER_REBOOT) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_ERROR(priv, IRQ, "Expecting for reboot barker %x,"
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "but got %x=
\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IWMC_BARKER=
_REBOOT,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (barker & B=
ARKER_DNLOAD_BARKER_MSK));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto exit_release;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "Rec=
ieved reboot barker: %x\n", barker);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 priv->barker =3D barker;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (barker & BARKER_DNLO=
AD_SYNC_MSK) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Send the same barker back */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ret =3D sdio_memcpy_toio(priv->func, IWMC_SDIO_DATA_ADDR,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0buf, iosize);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"erro=
r %d echoing barker\n", ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit_release;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_INFO(priv, IRQ, "Echoing barker to device\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 atomic_inc(&priv->dev_sync);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto exit_release;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> +
>> + =C2=A0 =C2=A0 case 1:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* we expect to recieve =
ACK BARKER */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (barker !=3D IWMC_BAR=
KER_ACK) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 LOG_INFO(priv, IRQ, "Expecting for ACK barker[%x],"
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"got this instead %x\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IWMC_BARKER_ACK, barker);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto exit_release;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(buf);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_set(&priv->dev_sy=
nc, 0);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_set(&priv->reset,=
 0);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> +
>> + =C2=A0 =C2=A0 default:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "Wro=
ng dev_sync %d\n", val);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 sdio_release_host(priv->func);
>> +
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "barker download request 0x%x is=
:\n", priv->barker);
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "******* =C2=A0Top FW %s request=
ed ********\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (priv->barker & BARKER_DNLOAD_TOP_MSK) ? "was" : "not");
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "******* =C2=A0GPS FW %s request=
ed ********\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (priv->barker & BARKER_DNLOAD_GPS_MSK) ? "was" : "not");
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "******* =C2=A0BT FW %s requeste=
d ********\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (priv->barker & BARKER_DNLOAD_BT_MSK) ? "was" : "not");
>> +
>> + =C2=A0 =C2=A0 if (priv->dbg.fw_download)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iwmct_fw_load(priv);
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ, "FW=
 download not allowed\n");
>> +
>> + =C2=A0 =C2=A0 return;
>> +
>> +exit_release:
>> + =C2=A0 =C2=A0 sdio_release_host(priv->func);
>> +exit:
>> + =C2=A0 =C2=A0 kfree(buf);
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "exit iwmct_irq_read_worker\n");
>> +}
>> +
>> +static void iwmct_irq(struct sdio_func *func)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv;
>> + =C2=A0 =C2=A0 int val, ret;
>> + =C2=A0 =C2=A0 int iosize;
>> + =C2=A0 =C2=A0 int addr =3D IWMC_SDIO_INTR_GET_SIZE_ADDR;
>> + =C2=A0 =C2=A0 struct iwmct_work_struct *read_req;
>> +
>> + =C2=A0 =C2=A0 priv =3D sdio_get_drvdata(func);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "enter iwmct_irq\n");
>> +
>> + =C2=A0 =C2=A0 /* read the function's status register */
>> + =C2=A0 =C2=A0 val =3D sdio_readb(func, IWMC_SDIO_INTR_STATUS_ADDR,=
 &ret);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "iir value =3D %d, ret=3D%d\n", =
val, ret);
>> +
>> + =C2=A0 =C2=A0 if (!val) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ, "ii=
r =3D 0, exiting ISR\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit_clear_intr;
>> + =C2=A0 =C2=A0 }
>> +
>> +
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* read 2 bytes of the transaction size
>> + =C2=A0 =C2=A0 =C2=A0* IMPORTANT: sdio transaction size has to be r=
ead before clearing
>> + =C2=A0 =C2=A0 =C2=A0* sdio interrupt!!!
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 val =3D sdio_readb(priv->func, addr++, &ret);
>> + =C2=A0 =C2=A0 iosize =3D val;
>> + =C2=A0 =C2=A0 val =3D sdio_readb(priv->func, addr++, &ret);
>> + =C2=A0 =C2=A0 iosize +=3D val << 8;
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "READ size %d\n", iosize);
>> +
>> + =C2=A0 =C2=A0 if (iosize =3D=3D 0) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ, "RE=
AD size %d, exiting ISR\n", iosize);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit_clear_intr;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* allocate a work structure to pass iosize to the w=
orker */
>> + =C2=A0 =C2=A0 read_req =3D kzalloc(sizeof(struct iwmct_work_struct=
), GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!read_req) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, IRQ, "fa=
iled to allocate read_req, exit ISR\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto exit_clear_intr;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 INIT_LIST_HEAD(&read_req->list);
>> + =C2=A0 =C2=A0 read_req->iosize =3D iosize;
>> +
>> + =C2=A0 =C2=A0 list_add_tail(&priv->read_req_list, &read_req->list)=
;
>> +
>> + =C2=A0 =C2=A0 /* clear the function's interrupt request bit (write=
 1 to clear) */
>> + =C2=A0 =C2=A0 sdio_writeb(func, 1, IWMC_SDIO_INTR_CLEAR_ADDR, &ret=
);
>> +
>> + =C2=A0 =C2=A0 queue_work(priv->wq, &priv->isr_worker);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, IRQ, "exit iwmct_irq\n");
>> +
>> + =C2=A0 =C2=A0 return;
>> +
>> +exit_clear_intr:
>> + =C2=A0 =C2=A0 /* clear the function's interrupt request bit (write=
 1 to clear) */
>> + =C2=A0 =C2=A0 sdio_writeb(func, 1, IWMC_SDIO_INTR_CLEAR_ADDR, &ret=
);
>> +}
>> +
>> +
>> +static int blocks;
>> +module_param(blocks, int, 0604);
>> +MODULE_PARM_DESC(blocks, "max_blocks_to_send");
>> +
>> +static int dump;
>> +module_param(dump, bool, 0604);
>> +MODULE_PARM_DESC(dump, "dump_hex_content");
>> +
>> +static int jump =3D 1;
>> +module_param(jump, bool, 0604);
>> +
>> +static int direct =3D 1;
>> +module_param(direct, bool, 0604);
>> +
>> +static int checksum =3D 1;
>> +module_param(checksum, bool, 0604);
>> +
>> +static int fw_download =3D 1;
>> +module_param(fw_download, bool, 0604);
>> +
>> +static int block_size =3D IWMC_SDIO_BLK_SIZE;
>> +module_param(block_size, int, 0404);
>> +
>> +static int download_trans_blks =3D IWMC_DEFAULT_TR_BLK;
>> +module_param(download_trans_blks, int, 0604);
>> +
>> +static int rubbish_barker;
>> +module_param(rubbish_barker, bool, 0604);
>
> Most of them are missing descriptions. And do we really need them? Wh=
at
> cases are they trying to work around?
>
>> +
>> +#ifdef CONFIG_IWMC3200TOP_DEBUG
>> +static int log_level[LOG_SRC_MAX];
>> +static unsigned int log_level_argc;
>> +module_param_array(log_level, int, &log_level_argc, 0604);
>> +MODULE_PARM_DESC(log_level, "log_level");
>> +
>> +static int log_level_fw[FW_LOG_SRC_MAX];
>> +static unsigned int log_level_fw_argc;
>> +module_param_array(log_level_fw, int, &log_level_fw_argc, 0604);
>> +MODULE_PARM_DESC(log_level_fw, "log_level_fw");
>> +#endif
>> +
>> +void iwmct_dbg_init_params(struct iwmct_priv *priv)
>> +{
>> +#ifdef CONFIG_IWMC3200TOP_DEBUG
>> + =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; i < log_level_argc; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_notice(&priv->func->=
dev, "log_level[%d]=3D0x%X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 i, log_level[i]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iwmct_log_set_filter((lo=
g_level[i] >> 8) & 0xFF,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0log_level[i] & 0xFF);
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 for (i =3D 0; i < log_level_fw_argc; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_notice(&priv->func->=
dev, "log_level_fw[%d]=3D0x%X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 i, log_level_fw[i]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iwmct_log_set_fw_filter(=
(log_level_fw[i] >> 8) & 0xFF,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 log_level_fw[i] & 0xFF);
>> + =C2=A0 =C2=A0 }
>> +#endif
>> +
>> + =C2=A0 =C2=A0 priv->dbg.blocks =3D blocks;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "blocks=3D%d\n", blocks);
>> + =C2=A0 =C2=A0 priv->dbg.dump =3D (bool)dump;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "dump=3D%d\n", dump);
>> + =C2=A0 =C2=A0 priv->dbg.jump =3D (bool)jump;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "jump=3D%d\n", jump);
>> + =C2=A0 =C2=A0 priv->dbg.direct =3D (bool)direct;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "direct=3D%d\n", direct);
>> + =C2=A0 =C2=A0 priv->dbg.checksum =3D (bool)checksum;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "checksum=3D%d\n", checksum);
>> + =C2=A0 =C2=A0 priv->dbg.fw_download =3D (bool)fw_download;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "fw_download=3D%d\n", fw_downlo=
ad);
>> + =C2=A0 =C2=A0 priv->dbg.block_size =3D block_size;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "block_size=3D%d\n", block_size=
);
>> + =C2=A0 =C2=A0 priv->dbg.download_trans_blks =3D download_trans_blk=
s;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "download_trans_blks=3D%d\n", d=
ownload_trans_blks);
>> +}
>> +
>> +/******************************************************************=
***********
>> + *
>> + * sysfs attributes
>> + *
>> + ******************************************************************=
***********/
>> +static ssize_t show_iwmct_fw_version(struct device *d,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct device_attribute *attr, c=
har *buf)
>> +{
>> + =C2=A0 =C2=A0 return sprintf(buf, "%s\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0((struct iwmct_priv *)d->driver_data)->dbg.label_fw);
>> +}
>> +static DEVICE_ATTR(cc_label_fw, S_IRUGO, show_iwmct_fw_version, NUL=
L);
>> +
>> +#ifdef CONFIG_IWMC3200TOP_DEBUG
>> +static DEVICE_ATTR(log_level, S_IWUSR | S_IRUGO,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0show_iwmct_=
log_level, store_iwmct_log_level);
>> +static DEVICE_ATTR(log_level_fw, S_IWUSR | S_IRUGO,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0show_iwmct_=
log_level_fw, store_iwmct_log_level_fw);
>> +#endif
>
> First module parameters and now device attributes. Why?
>
>> +
>> +static struct attribute *iwmct_sysfs_entries[] =3D {
>> + =C2=A0 =C2=A0 &dev_attr_cc_label_fw.attr,
>> +#ifdef CONFIG_IWMC3200TOP_DEBUG
>> + =C2=A0 =C2=A0 &dev_attr_log_level.attr,
>> + =C2=A0 =C2=A0 &dev_attr_log_level_fw.attr,
>> +#endif
>> + =C2=A0 =C2=A0 NULL
>> +};
>> +
>> +static struct attribute_group iwmct_attribute_group =3D {
>> + =C2=A0 =C2=A0 .name =3D NULL, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /=
* put in device directory */
>> + =C2=A0 =C2=A0 .attrs =3D iwmct_sysfs_entries,
>> +};
>> +
>> +
>> +static int iwmct_probe(struct sdio_func *func,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0const struct sdio_device_id *id)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv;
>> + =C2=A0 =C2=A0 int ret;
>> + =C2=A0 =C2=A0 int val =3D 1;
>> + =C2=A0 =C2=A0 int addr =3D IWMC_SDIO_INTR_ENABLE_ADDR;
>> +
>> + =C2=A0 =C2=A0 dev_info(&func->dev, "enter iwmct_probe\n");
>> +
>> + =C2=A0 =C2=A0 dev_info(&func->dev, "IRQ polling period id %u msecs=
, HZ is %d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 jiffies_to_msecs(2147483=
647), HZ);
>
> This is debug code. Don't use dev_info().
>
>> +
>> + =C2=A0 =C2=A0 priv =3D kzalloc(sizeof(struct iwmct_priv), GFP_KERN=
EL);
>> + =C2=A0 =C2=A0 if (!priv) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&func->dev, "kza=
lloc error\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 priv->func =3D func;
>> + =C2=A0 =C2=A0 sdio_set_drvdata(func, priv);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "HIDR supported\n");
>> +
>> + =C2=A0 =C2=A0 /* create drivers work queue */
>> + =C2=A0 =C2=A0 priv->wq =3D create_workqueue(DRV_NAME "_wq");
>> + =C2=A0 =C2=A0 priv->bus_rescan_wq =3D create_workqueue(DRV_NAME "_=
rescan_wq");
>> + =C2=A0 =C2=A0 INIT_WORK(&priv->bus_rescan_worker, iwmct_rescan_wor=
ker);
>> + =C2=A0 =C2=A0 INIT_WORK(&priv->isr_worker, iwmct_irq_read_worker);
>> +
>> + =C2=A0 =C2=A0 init_waitqueue_head(&priv->wait_q);
>> +
>> + =C2=A0 =C2=A0 sdio_claim_host(func);
>> + =C2=A0 =C2=A0 /* FIXME: Remove after it is fixed in the Boot ROM u=
pgrade */
>> + =C2=A0 =C2=A0 func->enable_timeout =3D 10;
>> +
>> + =C2=A0 =C2=A0 /* In our HW, setting the block size also wakes up t=
he boot rom. */
>> + =C2=A0 =C2=A0 ret =3D sdio_set_block_size(func, priv->dbg.block_si=
ze);
>> + =C2=A0 =C2=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, INIT,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "sdio_set_block_size() failure: %d\n", ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error_sdio_enable;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 ret =3D sdio_enable_func(func);
>> + =C2=A0 =C2=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, INIT, "s=
dio_enable_func() failure: %d\n", ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error_sdio_enable;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* init reset and dev_sync states */
>> + =C2=A0 =C2=A0 atomic_set(&priv->reset, 0);
>> + =C2=A0 =C2=A0 atomic_set(&priv->dev_sync, 0);
>> +
>> + =C2=A0 =C2=A0 /* init read req queue */
>> + =C2=A0 =C2=A0 INIT_LIST_HEAD(&priv->read_req_list);
>> +
>> + =C2=A0 =C2=A0 /* process configurable parameters */
>> + =C2=A0 =C2=A0 iwmct_dbg_init_params(priv);
>> + =C2=A0 =C2=A0 ret =3D sysfs_create_group(&func->dev.kobj, &iwmct_a=
ttribute_group);
>> + =C2=A0 =C2=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, INIT, "F=
ailed to register attributes and "
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0"initialize module_params\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error_dev_attrs;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 iwmct_dbgfs_register(priv, DRV_NAME);
>> +
>> + =C2=A0 =C2=A0 if (!priv->dbg.direct && priv->dbg.download_trans_bl=
ks > 8) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_INFO(priv, INIT,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0"Reducing transaction to 8 blocks =3D 2K (from %d)\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0priv->dbg.download_trans_blks);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 priv->dbg.download_trans=
_blks =3D 8;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 priv->trans_len =3D priv->dbg.download_trans_blks * =
priv->dbg.block_size;
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "Transaction length =3D %d\n", =
priv->trans_len);
>> +
>> + =C2=A0 =C2=A0 ret =3D sdio_claim_irq(func, iwmct_irq);
>> + =C2=A0 =C2=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, INIT, "s=
dio_claim_irq() failure: %d\n", ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error_claim_irq;
>> + =C2=A0 =C2=A0 }
>> +
>> +
>> + =C2=A0 =C2=A0 /* Enable function's interrupt */
>> + =C2=A0 =C2=A0 sdio_writeb(priv->func, val, addr, &ret);
>> + =C2=A0 =C2=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LOG_ERROR(priv, INIT, "F=
ailure writing to "
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 "Interrupt Enable Register (%d): %d\n", addr, ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error_enable_int;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 sdio_release_host(func);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "exit iwmct_probe\n");
>> +
>> + =C2=A0 =C2=A0 return ret;
>> +
>> +error_enable_int:
>> + =C2=A0 =C2=A0 sdio_release_irq(func);
>> +error_claim_irq:
>> + =C2=A0 =C2=A0 sdio_disable_func(func);
>> +error_dev_attrs:
>> + =C2=A0 =C2=A0 iwmct_dbgfs_unregister(priv->dbgfs);
>> + =C2=A0 =C2=A0 sysfs_remove_group(&func->dev.kobj, &iwmct_attribute=
_group);
>> +error_sdio_enable:
>> + =C2=A0 =C2=A0 sdio_release_host(func);
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +static void iwmct_remove(struct sdio_func *func)
>> +{
>> + =C2=A0 =C2=A0 struct iwmct_work_struct *read_req;
>> + =C2=A0 =C2=A0 struct iwmct_priv *priv =3D sdio_get_drvdata(func);
>> +
>> + =C2=A0 =C2=A0 priv =3D sdio_get_drvdata(func);
>> +
>> + =C2=A0 =C2=A0 LOG_INFO(priv, INIT, "enter\n");
>> +
>> + =C2=A0 =C2=A0 sdio_claim_host(func);
>> + =C2=A0 =C2=A0 sdio_release_irq(func);
>> + =C2=A0 =C2=A0 sdio_release_host(func);
>> +
>> + =C2=A0 =C2=A0 /* Safely destroy osc workqueue */
>> + =C2=A0 =C2=A0 destroy_workqueue(priv->bus_rescan_wq);
>> + =C2=A0 =C2=A0 destroy_workqueue(priv->wq);
>> +
>> + =C2=A0 =C2=A0 sdio_claim_host(func);
>> + =C2=A0 =C2=A0 sdio_disable_func(func);
>> + =C2=A0 =C2=A0 sysfs_remove_group(&func->dev.kobj, &iwmct_attribute=
_group);
>> + =C2=A0 =C2=A0 iwmct_dbgfs_unregister(priv->dbgfs);
>> + =C2=A0 =C2=A0 sdio_release_host(func);
>> +
>> + =C2=A0 =C2=A0 /* free read requests */
>> + =C2=A0 =C2=A0 while (!list_empty(&priv->read_req_list)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_req =3D list_entry(=
priv->read_req_list.next,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct iwmct_work_struct, list);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&read_req->list=
);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(read_req);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 kfree(priv);
>> +}
>> +
>> +
>> +static const struct sdio_device_id iwmct_ids[] =3D {
>> + =C2=A0 =C2=A0 { SDIO_DEVICE(SDIO_VENDOR_ID_INTEL, SDIO_DEVICE_ID_I=
NTEL_IWMC3200TOP)},
>> + =C2=A0 =C2=A0 { /* end: all zeroes */ },
>> +};
>> +
>> +MODULE_DEVICE_TABLE(sdio, iwmct_ids);
>> +
>> +static struct sdio_driver iwmct_driver =3D {
>> + =C2=A0 =C2=A0 .probe =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D iwmct_p=
robe,
>> + =C2=A0 =C2=A0 .remove =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D iwmct_remove=
,
>> + =C2=A0 =C2=A0 .name =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D DRV_NAM=
E,
>> + =C2=A0 =C2=A0 .id_table =C2=A0 =C2=A0 =C2=A0 =3D iwmct_ids,
>> +};
>> +
>> +static int __init iwmct_init(void)
>> +{
>> + =C2=A0 =C2=A0 int rc;
>> +
>> + =C2=A0 =C2=A0 /* Default log filter settings */
>> + =C2=A0 =C2=A0 iwmct_log_set_filter(LOG_SRC_ALL, LOG_SEV_FILTER_RUN=
TIME);
>> + =C2=A0 =C2=A0 iwmct_log_set_filter(LOG_SRC_FW_MSG, LOG_SEV_FILTER_=
ALL);
>> + =C2=A0 =C2=A0 iwmct_log_set_fw_filter(LOG_SRC_ALL, FW_LOG_SEV_FILT=
ER_RUNTIME);
>> +
>> + =C2=A0 =C2=A0 rc =3D sdio_register_driver(&iwmct_driver);
>> +
>> + =C2=A0 =C2=A0 return rc;
>> +}
>
> Actually return sdio_register_driver() would do the same trick.
>
>> +
>> +static void __exit iwmct_exit(void)
>> +{
>> + =C2=A0 =C2=A0 sdio_unregister_driver(&iwmct_driver);
>> +}
>> +
>> +module_init(iwmct_init);
>> +module_exit(iwmct_exit);
>> +
>
> At some point I got lost in this code. It contains more debug stateme=
nts
> and infrastructure than actual code as it seems. Can you please clean
> this up. I mentioned it above. Just use dynamic_printk and you should=
 be
> have something clean and simple.
>
> Regards
>
> Marcel
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-mmc" =
in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
