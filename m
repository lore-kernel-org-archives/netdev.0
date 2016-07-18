From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] wlcore/wl18xx: mesh: added initial mesh support for wl8
Date: Mon, 18 Jul 2016 20:42:57 +0300
Message-ID: <87eg6qx2ou.fsf@kamboji.qca.qualcomm.com>
References: <20160628104305.4533-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, Maital Hahn <maitalm@ti.com>,
	Eliad Peller <eliad@wizery.com>, Guy Mishol <guym@ti.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Arik Nemtsov <arik@wizery.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Yaniv Machani <yanivma@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58834 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbcGRRnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 13:43:10 -0400
In-Reply-To: <20160628104305.4533-1-yanivma@ti.com> (Yaniv Machani's message
	of "Tue, 28 Jun 2016 13:41:35 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yaniv Machani <yanivma@ti.com> writes:

> From: Maital Hahn <maitalm@ti.com>
>
> 1. Added support for interface and role of mesh type.
> 2. Enabled enable/start of mesh-point role,
>    and opening and closing a connection with a mesh peer.
> 3. Added multirole combination of mesh and ap
>    under the same limits of dual ap mode.
> 4. Add support for 'sta_rc_update' opcode for mesh IF.
>    The 'sta_rc_update' opcode is being used in mesh_plink.c.
> Add support in wlcore to handle this opcode correctly for mesh
> (as opposed to current implementation that handles STA only).
> 5. Bumped the firmware version to support new Mesh functionality
>
> Signed-off-by: Maital Hahn <maitalm@ti.com>
> Signed-off-by: Yaniv Machani <yanivma@ti.com>

Does this depend on any mac80211 patches? To not break anything I can't
apply this until all the dependencies are in my tree.

-- 
Kalle Valo
