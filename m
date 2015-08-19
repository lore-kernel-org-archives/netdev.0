From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 0/2] Small cleanups for smsc and device property
Date: Wed, 19 Aug 2015 11:46:41 -0500
Message-ID: <1440002803-5113-1-git-send-email-jeremy.linton@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: gregkh@linuxfoundation.org, steve.glendinning@shawell.net,
	linux@roeck-us.net, jeremy.linton@arm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([207.82.80.143]:47370 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751576AbbHSQrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:47:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are against net-next.

This patch set adds a length check to device_get_mac_addr() before
calling is_valid_ether_addr(), it also removes an unisssary dev=3D=3Dnull
check.

The remainder is updates to the comments.

Jeremy Linton (2):
  device property: Add ETH_ALEN check, update comments.
  smsc911x: Remove dev=3D=3DNULL check.

 drivers/base/property.c              | 21 +++++++++++++--------
 drivers/net/ethernet/smsc/smsc911x.c |  3 ---
 2 files changed, 13 insertions(+), 11 deletions(-)

--=20
2.4.3
