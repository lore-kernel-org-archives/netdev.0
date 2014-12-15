From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/5] e1000e: fix nic not boot after rebooting
Date: Mon, 15 Dec 2014 09:48:05 +0100
Message-ID: <20141215084805.GF7349@1wt.eu>
References: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: Zhu Yanjun <zyjzyj2000@gmail.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2647 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbaLOIsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 03:48:09 -0500
Content-Disposition: inline
In-Reply-To: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Dec 15, 2014 at 04:39:09PM +0800, Zhu Yanjun wrote:
> With kernel 2.6.x, e1000e with 82577/8/9 sometimes will not boot
> after rebooting. 
> 
> If a kernel 2.6.x board with 82577/8/9 e1000e nic is rebooted for 
> 100 times, there are 7~8 times that 82577/8/9 e1000e nic will not boot 
> normally.
> 
> Zhu Yanjun (5):
>   e1000e: reset MAC-PHY interconnect on 82577/82578
>   e1000e: workaround EEPROM configuration change on 82579 on kernel
>     2.6.x
>   e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
>   e1000e: update workaround for 82579 intermittently disabled during
>     S0->Sx
>   e1000e: cleanup use of check_reset_block function pointer

Great, thanks! Jeff/Bruce, do you have any objection against me applying
these fixes to 2.6.32 ?

Thanks,
Willy
