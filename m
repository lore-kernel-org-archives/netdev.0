From: Pelle Svensson <pelle2004@hotmail.com>
Subject: Intel 82567LM e1000e DHCP problem/question
Date: Sun, 15 Mar 2009 15:04:06 +0100
Message-ID: <BAY143-W41A6A9A51EDB64905CA4D1B99A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s32.bay0.hotmail.com ([65.54.246.104]:38418 "EHLO
	bay0-omc1-s32.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751031AbZCOOKS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 10:10:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi,

Quick question.

Is there any functionality inside the driver for DHCP request.
I see in the source that there is some kind of DHCP filter f the tx str=
eam.
Can the drive issue DHCP request inside it self when the Cable is unplu=
gged/plugged.

I'm tracing a DHCP fault.=20
When the net is brought down, ifdown eth0, the dhclient is killed.
Then when I unplugged/plugged the cable I get a DHCP request even that=20
dhclient is down.

Also the Wireshark format of the DHCP request are different.
Correct request includes from dhclient has:
> Option: (t=3D12,l=3D5) Host Name =3D "pc005"
Incorrect requests when dhclient is killed dose not have above.


/Thanks

_________________________________________________________________
Dela foton p=E5 ett smidigt s=E4tt med Windows Live=99 Photos.
http://www.microsoft.com/windows/windowslive/products/photos.aspx