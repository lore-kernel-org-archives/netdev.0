From: Ben Chan <benchan@chromium.org>
Subject: [PATCH net-next v4 0/2] adjust MTU as indicated by MBIM extended functional descriptor
Date: Wed, 19 Mar 2014 14:00:04 -0700
Message-ID: <1395262806-19237-1-git-send-email-benchan@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>
To: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MBIM extended functional descriptor, defined in "Universal Serial B=
us
Communications Class Subclass Specification for Mobile Broadband Interf=
ace
Model, Revision 1.0, Errata-1" by USB-IF, indicates the operator prefer=
red MTU
value via a wMTU field.

This patch set ensures that the initial MTU value set by cdc_ncm on a M=
BIM net
device does not exceed the wMTU value, provided the MBIM device exposes=
 a MBIM
extended functional descriptor.

* Changelog
v2: Fixed a le16_to_cpu conversion issue in patch 2/2 pointed out by
    Bj=C3=B8rn Mork <bjorn@mork.no>
v3: No code changes. Resubmitted to include patch 1/2 as suggested by
    David Miller <davem@davemloft.net>
v4: No code changes. Resubmitted as suggested by David Miller:
    - Added a summary of the patch set
    - Carried the ACK from Greg Kroah-Hartman <gregkh@linuxfoundation.o=
rg>
    - Added a specified the tree (net-next) to apply the patch set to

Ben Chan (2):
  USB: cdc: add MBIM extended functional descriptor structure
  net: cdc_ncm: respect operator preferred MTU reported by MBIM

 drivers/net/usb/cdc_ncm.c    | 17 +++++++++++++++++
 include/linux/usb/cdc_ncm.h  |  1 +
 include/uapi/linux/usb/cdc.h | 12 ++++++++++++
 3 files changed, 30 insertions(+)

--=20
1.9.0.279.gdc9e3eb
