From: Denis Joseph Barrow <D.Barow@option.com>
Subject: using the hso driver with cisco vpn client
Date: Thu, 09 Oct 2008 15:39:27 +0200
Message-ID: <48EE098F.8040407@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070501020906080106010207"
Cc: Linux netdev Mailing list <netdev@vger.kernel.org>,
	Paul Hardwick <P.Hardwick@option.com>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>
To: =?ISO-8859-1?Q?N=E9meth_Tam=E1s?= <nice@titanic.nyme.hu>,
	Filip Aben <f.aben@option.com>,
	Cisco Technical Support <tac@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:55883 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757694AbYJINjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 09:39:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070501020906080106010207
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Tamas,
I just realised something. You don't need a faked ethernet port in the hso driver to get ciscos vpn
client to work, I found out in the last few days that the modem port works
just fine on the hso driver despite the misleading comment which implies otherwise.
You should be able to use the modem interface in the hso driver to make a ppp connection,
this should work with your vpn cisco client
I've included a sample wvdial script which I use to make my connection.
You can use to ./ports.sh script from our 1.6 distribution on pharscape to find
the modem port of the 3g modem

-- 
best regards,
D.J. Barrow

--------------070501020906080106010207
Content-Type: text/plain;
 name="wvdial.conf"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="wvdial.conf"

[Dialer Defaults]
Modem = /dev/ttyHS4
Stupid Mode = 1
Init = AT+CGDCONT=1,,"internet.proximus.be"
Dial = ATD
Phone = *99#
Username = vodaphone
Password = vodaphone
Carrier Check = 1 
#New PPPD = yes

--------------070501020906080106010207--
