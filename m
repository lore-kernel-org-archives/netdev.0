From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Patches depending on changes in usb-next
Date: Tue, 19 Jun 2012 12:52:24 +0200
Message-ID: <877gv3po9j.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44071 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239Ab2FSKwb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 06:52:31 -0400
Received: from nemi.mork.no (ip6-localhost [IPv6:::1])
	by canardo.mork.no (8.14.3/8.14.3) with ESMTP id q5JAqO77014605
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2012 12:52:25 +0200
Received: from bjorn by nemi.mork.no with local (Exim 4.77)
	(envelope-from <bjorn@mork.no>)
	id 1Sgw2q-0006Kb-9m
	for netdev@vger.kernel.org; Tue, 19 Jun 2012 12:52:24 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a couple of 3.6 patches for the qmi_wwan driver which depend on

  81df2d5 USB: allow match on bInterfaceNumber
  fec1868 USB: properly pad out usb_device_id.driver_info

only available in usb-next.  Do you prefer that I hold on to these unti=
l
after the 3.6 merge window?  They only affect module aliases and
probing so the risk isn't too high, although they do represent quite
major changes in that particular area.


Bj=C3=B8rn
