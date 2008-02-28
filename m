From: "Kevin Lloyd" <klloyd@sierrawireless.com>
Subject: Network device driver with PPP
Date: Wed, 27 Feb 2008 17:28:05 -0800
Message-ID: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from carmdsmtp.sierrawireless.com ([208.81.121.7]:53118 "EHLO
	mx1.sierrawireless.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbYB1B0V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 20:26:21 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have a device that is currently supported via a combination of loadin=
g the device with usb-serial (drivers/usb/serial/sierra) to expose the =
serial ports and connecting by manually launching pppd.
I would like to support this device in a network driver as opposed to a=
 serial driver in an effort to offer a seamless always-on device, such =
as an Ethernet device.

=46rom what I understand the ppp support in the kernel is only for ppp =
framing and that all control (e.g., IPCP) is done in user-space via ppp=
d. Are there any network drivers that currently manage the ppp connecti=
on (entirely, IPCP included) internally to the driver and expose either=
 a raw ip or ethernet stream to the user-space?

Thank you,
=A0-Kevin

