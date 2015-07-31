From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: how to access PHY's registers from user space
Date: Fri, 31 Jul 2015 04:39:18 +0000
Message-ID: <BN3PR03MB14796C65DAA12CB9AB851E1EE28A0@BN3PR03MB1479.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0141.outbound.protection.outlook.com ([157.56.111.141]:44000
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751069AbbGaEjU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 00:39:20 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry!
I have to re-send the email since previous one was rejected due to HTML=
 format.

Best Regards,=20
Shaohui Xie

=46rom: Xie Shaohui-B21989=20
Sent: Friday, July 31, 2015 12:09 PM
To: netdev@vger.kernel.org; 'David Miller'
Subject: how to access PHY's registers from user space

Hello All,
Is there a general way in user space to access C45 PHY's registers, lik=
e dumping some registers?

mii-tool seems obsolete, especially, it cannot support PHYs accessed th=
rough Clause 45.

ethtool seems does not support this operation.

PHY lib API phy_mii_ioctl() seems also obsolete, data structure it used=
 is not suitable for C45 PHYs.

/* This structure is used in all SIOCxMIIxxx ioctl calls */
struct mii_ioctl_data {
=A0=A0=A0=A0=A0=A0=A0 __u16=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 phy_id;
=A0=A0=A0=A0=A0=A0=A0 __u16=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 reg_num;
=A0=A0=A0=A0=A0=A0=A0 __u16=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 val_in;
=A0=A0=A0=A0=A0=A0=A0 __u16=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 val_out;
};=A0=A0=20

What should be a proper way to implement accessing PHY's registers in u=
ser space?=20

To modify the phy_mii_ioctl() to support C45 PHYs?=20
Then how about the user space application, should it also be improved?

Or to add sysfs support to a specific PHY's driver if this PHY is inter=
ested,=20
is this acceptable in upstream?

Welcome to comments!

Best Regards,=20
Shaohui Xie
