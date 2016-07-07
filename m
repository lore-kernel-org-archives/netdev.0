From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: mask PCIe interrupts before removal
Date: Thu, 07 Jul 2016 22:37:59 +0300
Message-ID: <877fcxck88.fsf@purkki.adurom.net>
References: <1467325262-82799-1-git-send-email-briannorris@chromium.org>
	<20160707181652.GA70075@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	linux-kernel@vger.kernel.org,
	Doug Anderson <dianders@chromium.org>,
	Brian Norris <computersforpeace@gmail.com>,
	Stephen Barber <smbarber@chromium.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	wnhuang@chromium.org
To: Brian Norris <briannorris@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39972 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbcGGTiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 15:38:06 -0400
In-Reply-To: <20160707181652.GA70075@google.com> (Brian Norris's message of
	"Thu, 7 Jul 2016 11:16:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Norris <briannorris@chromium.org> writes:

> Hi,
>
> On Thu, Jun 30, 2016 at 03:21:02PM -0700, Brian Norris wrote:
>> The PCIe driver didn't mask the host interrupts before trying to tear
>> down. This causes lockups at reboot or rmmod when using MSI-X on 8997,
>> since the MSI handler gets confused and locks up the system.
>> 
>> Also tested on 8897, which does not support MSI-X (and wasn't
>> experiencing this same bug). No regressions seen there.
>
> Ping? This is a bugfix, and it'd be nice to either know what's wrong
> with it, or see it merged.

It's on my queue for 4.8:

https://patchwork.kernel.org/patch/9209027/

-- 
Kalle Valo
