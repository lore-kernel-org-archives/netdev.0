From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] wlcore/wl18xx: mesh: added initial mesh support for wl8
Date: Thu, 14 Jul 2016 15:04:40 +0300
Message-ID: <87k2goxw6f.fsf@kamboji.qca.qualcomm.com>
References: <20160628104305.4533-1-yanivma@ti.com>
	<AE1C82FB3D0EC64DB1F752C81CBD1101391FC336@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Hahn\, Maital" <maitalm@ti.com>, Eliad Peller <eliad@wizery.com>,
	"Mishol\, Guy" <guym@ti.com>,
	Johannes Berg <johannes.berg@intel.com>,
	"Arik Nemtsov" <arik@wizery.com>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: "Machani\, Yaniv" <yanivma@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45953 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbcGNMEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 08:04:47 -0400
In-Reply-To: <AE1C82FB3D0EC64DB1F752C81CBD1101391FC336@DFRE01.ent.ti.com>
	(Yaniv Machani's message of "Wed, 13 Jul 2016 09:53:35 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Machani, Yaniv" <yanivma@ti.com> writes:

> On Tue, Jun 28, 2016 at 13:41:35, Machani, Yaniv wrote:
>> Guy; Johannes Berg; Arik Nemtsov; linux-wireless@vger.kernel.org; 
>> netdev@vger.kernel.org
>> Subject: [PATCH] wlcore/wl18xx: mesh: added initial mesh support for 
>> wl8
>> 
>> From: Maital Hahn <maitalm@ti.com>
>> 
>> 1. Added support for interface and role of mesh type.
>> 2. Enabled enable/start of mesh-point role,
>>    and opening and closing a connection with a mesh peer.
>> 3. Added multirole combination of mesh and ap
>>    under the same limits of dual ap mode.
>> 4. Add support for 'sta_rc_update' opcode for mesh IF.
>>    The 'sta_rc_update' opcode is being used in mesh_plink.c.
>> Add support in wlcore to handle this opcode correctly for mesh (as 
>> opposed to current implementation that handles STA only).
>> 5. Bumped the firmware version to support new Mesh functionality
>> 
>> Signed-off-by: Maital Hahn <maitalm@ti.com>
>> Signed-off-by: Yaniv Machani <yanivma@ti.com>
>> ---
>
> Any comments on this patch ? Can this be pulled ?

I'm away this week, will look at it next week. But it's on my queue:

https://patchwork.kernel.org/patch/9202707/

-- 
Kalle Valo
