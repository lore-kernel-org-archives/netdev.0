From: Fabio Estevam <festevam@gmail.com>
Subject: Re: suspend/resume broken on 3.18-rc2
Date: Wed, 29 Oct 2014 09:47:46 -0200
Message-ID: <CAOMZO5C9tcL9K79rwWbYkYcpRMPkpvHS+v2kYyRpY4bt7h=Cgw@mail.gmail.com>
References: <CAOMZO5C5znc2ZD5GoPKC7qQPoFGaJf47BoTMY0HQtEbW46d4dw@mail.gmail.com>
	<6278a77cdc594b3488b0ebc043f7d17b@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Russell King <linux@arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	Anson Huang <b20788@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:57494 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932384AbaJ2Lrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 07:47:48 -0400
Received: by mail-la0-f48.google.com with SMTP id gq15so2388481lab.35
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 04:47:46 -0700 (PDT)
In-Reply-To: <6278a77cdc594b3488b0ebc043f7d17b@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2014 at 3:46 AM, fugang.duan@freescale.com
<fugang.duan@freescale.com> wrote:

> Hi, Fabio,
>
> I test 3.18.0-rc2, and has some problems:
> - most of time, imx6sx-sdb cannot resume back regardless of nfs or SD rootfs, and power key also cannnot resume back.
> - when do "echo core > /sys/power/pm_test", and then do suspend/resume test, console key can wake up system, but no broken issue found in nfs.

Adding Anson in case he could look into this problem from a power
management perspective.
