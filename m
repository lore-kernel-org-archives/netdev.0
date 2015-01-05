From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcm80211: brcmsmac: dma: Remove some unused functions
Date: Mon, 05 Jan 2015 12:34:27 +0200
Message-ID: <878uhh3498.fsf@kamboji.qca.qualcomm.com>
References: <1420332469-5907-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<54A8DBF4.4050202@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Fabian Frederick <fabf@skynet.be>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54A8DBF4.4050202@lwfinger.net> (Larry Finger's message of "Sun,
	04 Jan 2015 00:21:40 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger@lwfinger.net> writes:

> On 01/03/2015 06:47 PM, Rickard Strandqvist wrote:
>> Removes some functions that are not used anywhere:
>> dma_txflush() dma_txsuspended()
>>
>> This was partially found by using a static code analysis program called cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>> ---
>>   drivers/net/wireless/brcm80211/brcmsmac/dma.c |   19 -------------------
>>   drivers/net/wireless/brcm80211/brcmsmac/dma.h |    2 --
>>   2 files changed, 21 deletions(-)
>
> Just because file dma.c is involved, it does not need to be, nor
> should it be in the subject line. You could specify the driver names
> in the file tree after wireless. In this instance, one possible
> subject would be "brcm80211: brcmsmac: Remove some unused functions".
> On the other hand, if you look at "git log" to see past patches, the
> driver maintainers even leave off the brcm80211 part, thus to match
> them, the subject should be "brcmsmac: Remove some unused functions".

This is a handy way to check what kind of format you should use:

$ git log --oneline --no-merges drivers/net/wireless/brcm80211/brcmsmac/dma.c | head
a38a9ef1c064 brcm80211: use container_of to resolve dma_info from dma_pub
67d0cf50bd32 brcmsmac: Fix WARNING caused by lack of calls to dma_mapping_error()
55cec505559d brcmsmac: Fix possible NULL pointer dereference in _dma_ctrlflags()
9242c7261b8c brcmsmac: Remove some noisy and uninformative debug messages
0c9a0a1dd145 brcmsmac: Add tracepoint for AMPDU session information
90123e045cac brcmsmac: Add brcms_dbg_dma() debug macro
b05618deb4ac brcmsmac: Use correct descriptor count when calculating next rx descriptor
e041f65d5f00 brcmsmac: Remove internal tx queue
05f8a6160491 brcmsmac: Add helper function for updating txavail count
ec5ab1dd73a4 brcmsmac: fix DMA on SoCs

> As was suggested earlier, you need to look at the precedents. Keeping
> a uniform method of patch naming helps when looking for patches in the
> git log.

Yeah, and also having clean[1] patch titles makes working with patchwork
so much easier and hence me happier :)

[1] clean patch title == short, clear and unique

-- 
Kalle Valo
