From: =?ISO-8859-2?Q?=A9tefan_Sakal=EDk?= <rabbit6440@gmail.com>
Subject: Devices with colon in name (iproute2 bug)
Date: Thu, 18 Nov 2010 13:14:46 +0100
Message-ID: <AANLkTimw7=zS8YNptNNP9YR0v93EwctBvsG58a4z+Y-M@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:51919 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab0KRMOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 07:14:48 -0500
Received: by gwj17 with SMTP id 17so1755123gwj.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 04:14:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
When I add a device with colon via ip (from git 3f5c1a01):
ip link add dev 'a:b' type dummy
then ip link show dev 'a:b' returns
12: a:b: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
ioctl(SIOCGIFXQLEN) failed: No such device

link/ether 9e:44:b4:ec:77:f1 brd ff:ff:ff:ff:ff:ff

Also ifconfig from net-tools returns
a: error fetching interface information: Device not found
but I guess it's obsolete.

Regards,
-Stefan
