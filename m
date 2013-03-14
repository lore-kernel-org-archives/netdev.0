From: Mark Jackson <mpfj-list@mimc.co.uk>
Subject: Re: [PATCH v3 net-next 1/1] drivers: net: davinci_cpdma: acknowledge
 interrupt properly
Date: Thu, 14 Mar 2013 10:27:49 +0000
Message-ID: <5141A625.8000704@mimc.co.uk>
References: <1361175560-600-1-git-send-email-mugunthanvnm@ti.com> <51404838.2040008@mimc.co.uk> <5141A4A3.4050204@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <5141A4A3.4050204@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/03/13 10:21, Mugunthan V N wrote:
> On 3/13/2013 3:04 PM, Mark Jackson wrote:
>> On 18/02/13 08:19, Mugunthan V N wrote:
>>> >CPDMA interrupts are not properly acknowledged which leads to interrupt
>>> >storm, only cpdma interrupt 0 is acknowledged in Davinci CPDMA driver.
>>> >Changed cpdma_ctlr_eoi api to acknowledge 1 and 2 interrupts which are
>>> >used for rx and tx respectively.
>>> >
>>> >Reported-by: Pantelis Antoniou<panto@antoniou-consulting.com>
>>> >Signed-off-by: Mugunthan V N<mugunthanvnm@ti.com>
>> Not sure if I'm seeing this same problem [1], but it doesn't appear fixed to me.
>>
>> I've tried both mainline -rc2 and -next.
>>
>> [1]https://lkml.org/lkml/2013/3/12/376
> Without this patch, PG2.0 was not usable as CPSW interrupt was never acked
> and CPU spent most of the time in CPSW ISR.
> 
> I have checked -rc2 and it is working fine.

I needed to add patch [1] to fix my problem.  See thread [2].

[1] https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=d35162f89b8f00537d7b240b76d2d0e8b8d29aa0
[2] https://lkml.org/lkml/2013/3/13/146

Cheers
Mark J.
