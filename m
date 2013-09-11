From: Christian Ege <k4230r6@gmail.com>
Subject: How to enable extended Ethtool support for SOCs like the i.mx6
Date: Wed, 11 Sep 2013 16:37:29 +0200
Message-ID: <CAALGJZZCnW+7_ChjHSiC=F+HPz0mZ+-xhRcO5gT-qBL4=xevpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:52981 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595Ab3IKOh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 10:37:29 -0400
Received: by mail-ie0-f179.google.com with SMTP id e14so4883908iej.38
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 07:37:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I am currently developping on a freescale i.mx6 custom design with a
Micrel ksz9031 Phy. Both are supported by Linux. The adjustment of
speed and duplex modes can be done by ethtool without any problems.

Then our hardware department started a request to toggle mdi and mdi-x
modes,this is done through the vendor specific Register 0x1C, of the
PHY. The PHY itself supports this feature. But I can not find any
clear way to add this support in the Kernel.

The ethtool communicates over the freescale fec driver with the PHY.
The FEC Driver itself does not really know what PHY it is attached to.
The only examples about the mdi/mdi-x features in the kernel are
located in the intel drivers which I think do know which PHY
capabilities they can rely on.

What is the preferred way to make this settings available to the user-space?

Is extending the phy_device struct a way to go?


with kind regards,

Christian Ege
