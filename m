From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] hyperv: Add netpoll support
Date: Wed, 9 Jul 2014 00:47:24 +0200
Message-ID: <20140708224724.GA2994@electric-eye.fr.zoreil.com>
References: <1404811947-5174-1-git-send-email-richard@nod.at>
 <9fb91c2ee32a4a59a2bec54043a6b9fd@BY2PR03MB299.namprd03.prod.outlook.com>
 <53BC3AC5.6000203@nod.at>
 <b2835410139848be8811403e3d7fa708@BY2PR03MB299.namprd03.prod.outlook.com>
 <53BC51B4.4010703@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43549 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbaGHWrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 18:47:46 -0400
Content-Disposition: inline
In-Reply-To: <53BC51B4.4010703@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Weinberger <richard@nod.at> :
[...]
> This won't work as netpoll runs with IRQs disabled.
> ->ndo_poll_controller() has to make sure that SKBs can be received and transmitted
> while IRQs are off. I thought calling the channel callback by hand would be
> enough to receive SKBs.

What are you taking about ? netconsole does not need to receive.

hyperv start_xmit handler almost does its own Tx completion as you have
noticed. The situation is imho close to a virtual device one as was veth
in bb446c19fefd7b4435adb12a9dd7666adc5b553a.

-- 
Ueimor
