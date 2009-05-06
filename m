From: Upakul Barkakaty <upakul@gmail.com>
Subject: mv643xx_eth: Delay required in reading the PHY registers.
Date: Wed, 6 May 2009 11:08:07 +0530
Message-ID: <bb58ac4d0905052238m59ca2767i1e84d90b6abb46d4@mail.gmail.com>
References: <bb58ac4d0905010108n77ca98c8t59409952150c3a11@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:36399 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756436AbZEFFiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 01:38:08 -0400
Received: by an-out-0708.google.com with SMTP id d40so8222174and.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2009 22:38:07 -0700 (PDT)
In-Reply-To: <bb58ac4d0905010108n77ca98c8t59409952150c3a11@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am using the Marvell ethernet driver[mv643xx_eth]. The function
eth_port_read_smi_reg(), uses a delay in order to wait for the SMI
register to become available.

Does anyone have any clue how much time it actually takes for the SMI
register to become available? Actually I am using an older version of
the driver which does not use the udelay functions in the loops. It
rather has a "for" loop for putting a timeout. Now the gcc-4.3.1
compiler optimizes out the "for" loop. So I need to replace the "for"
loop with a delay function. Now the question is "how much delay would
be appropriate".

Any replies in this regard would be appreciated.

--
Regards,
Upakul Barkakaty
