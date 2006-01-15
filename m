From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Sun, 15 Jan 2006 16:19:58 +0300
Message-ID: <20060115161958.07e3c7f1@vitb.dev.rtsoft.ru>
References: <20060105181826.GD12313@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, saw@saw.sw.com.sg, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751928AbWAONUF@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060105181826.GD12313@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Jan 2006 19:18:26 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> This patch removes the obsolete drivers/net/eepro100.c driver.
> 
> Is there any known problem in e100 still preventing us from removing 
> this driver (it seems noone was able anymore to verify the ARM problem)?
> 
I think I am recalling some problems on ppc82xx, when e100 was stuck on startup,
and eepro100 worked just fine. 

Even if the patch below will be scheduled for application, we need to set up enough time 
for approval that e100 will be fine for all the up-to-date hw; or it should be fixed/updated before eepro100 removal.

> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
>


-- 
Sincerely, 
Vitaly
