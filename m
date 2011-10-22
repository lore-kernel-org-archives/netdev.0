From: "Mantas M." <grawity@gmail.com>
Subject: Re: [PATCH] jme: fix irq storm after suspend/resume
Date: Sat, 22 Oct 2011 19:27:09 +0300
Message-ID: <j7uqst$kpc$1@dough.gmane.org>
References: <20111022125620.GA2256@ecki.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111022125620.GA2256@ecki.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/10/11 15:56, Clemens Buchacher wrote:
> If the device is down during suspend/resume, interrupts are enabled
> without a registered interrupt handler, causing a storm of
> unhandled interrupts until the IRQ is disabled because "nobody
> cared".
>
> Instead, check that the device is up before touching it in the
> suspend/resume code.
>
> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=39112

Just tested the patch, suspend/resume works well.

-- 
Mantas M.
