From: "Naveen B N (nbn)" <nbn@cisco.com>
Subject: Get TOS from IP header
Date: Tue, 22 Nov 2011 07:06:53 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA01F7DDEC@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ams-iport-3.cisco.com ([144.254.224.146]:33288 "EHLO
	ams-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab1KVBg4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 20:36:56 -0500
Received: from xbh-bgl-412.cisco.com (xbh-bgl-412.cisco.com [72.163.129.202])
	by bgl-core-2.cisco.com (8.14.3/8.14.3) with ESMTP id pAM1asvC011859
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 01:36:54 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I want=A0 to get the TOS field content from IP header at=20
my application which is using SCTP protocol.
I know that it can be done by Using RAW socket but=20
There is a over head of implementing the sctp at the=20
Application layer .=20
Is there a better way of getting a TOS field filled
Which we received from IP header.

I taught of adding code in kernel to recognize a socket option at the k=
ernel,
If this option is set just and get TOS contents in receive .

Please let me know if this is the way to go about it or is there=20
A better way to achieve the same .

Thanks and Regards
Naveen
