From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Wait for boot code to finish after power on
Date: Thu, 13 Jun 2013 02:42:35 -0700 (PDT)
Message-ID: <20130613.024235.1657219452701408875.davem@davemloft.net>
References: <1371060539-27837-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1371060539-27837-1-git-send-email-nsujir@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Wed, 12 Jun 2013 11:08:59 -0700

> Some systems that don't need wake-on-lan may choose to power down the
> chip on system standby. Upon resume, the power on causes the boot code
> to startup and initialize the hardware. On one new platform, this is
> causing the device to go into a bad state due to a race between the
> driver and boot code, once every several hundred resumes. The same race
> exists on open since we come up from a power on.
> 
> This patch adds a wait for boot code signature at the beginning of
> tg3_init_hw() which is common to both cases. If there has not been a
> power-off or the boot code has already completed, the signature will be
> present and poll_fw() returns immediately. Also return immediately if
> the device does not have firmware.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
