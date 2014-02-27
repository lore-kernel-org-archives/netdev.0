From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] ethtool: allow for a smaller build
Date: Thu, 27 Feb 2014 10:05:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CC891@AcuExch.aculab.com>
References: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
 <1393464911-21593-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:32848 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750781AbaB0KG1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:06:27 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24934-03 for <netdev@vger.kernel.org>;
 Thu, 27 Feb 2014 10:06:26 +0000 (GMT)
In-Reply-To: <1393464911-21593-3-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli
> Introduce a new configure script option: --enable-small which will
> disable building the driver specific register dump objects, the savings
> are:
...
> +if !SMALL
> +ethtool_SOURCES += \
>  		  amd8111e.c de2104x.c e100.c e1000.c et131x.c igb.c	\
>  		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
>  		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
>  		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
> -		  rxclass.c sfpid.c sfpdiag.c ixgbevf.c
> +		  sfpid.c sfpdiag.c ixgbevf.c
> +endif

What about allowing a subset of the register dumps be enabled?

	David
