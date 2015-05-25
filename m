From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers-next 2015-05-21
Date: Mon, 25 May 2015 13:57:33 +0300
Message-ID: <87wpzw3owx.fsf@kamboji.qca.qualcomm.com>
References: <87k2w26oef.fsf@kamboji.qca.qualcomm.com>
	<20150524.232955.425320477500361631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	michal.kazior@tieto.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44065 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbbEYK5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 06:57:41 -0400
In-Reply-To: <20150524.232955.425320477500361631.davem@davemloft.net> (David
	Miller's message of "Sun, 24 May 2015 23:29:55 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Thu, 21 May 2015 16:39:04 +0300
>
>> here's a wireless-drivers pull request for 4.2. This time please pay
>> extra attention to this pull as there are two problems:
>> 
>> First of all as you can see the diffstat from git-pull-request in the
>> end is just weird. I was long and hard trying to check everything and to
>> my understanding all the merges look ok and I cannot explain the reason
>> for the diffstat, but of course I might be missing something. Maybe
>> git-request-pull is just buggy? At least with gitk everything looks to
>> be ok and the patch list below also looks valid.
>
> The diffstat doesn't look anything like that for me.  It contained only
> your wireless changes.
>
> It may have helped that I merged 'net' into 'net-next' right before I
> pulled this.

Good to hear.

>> Secondly there's a non-trivial conflict in
>> drivers/net/wireless/ath/ath10k/mac.c which is due to removal of
>> FIF_PROMISC_IN_BSS in commit df1404650c. You need to remove more code
>> than just the obvious conflicts shown by git. In the end of this mail I
>> added a git diff output after I fixed the conflict, hopefully that helps
>> you to fix it. The main points are that you remove
>> ath10k_mac_should_disable_promisc() and the last ath10k_monitor_recalc()
>> call from ath10k_vdev_start_restart() along with the obvious conflict
>> fixes git points out.
>> 
>> There's also a patch from Michal which will also help to fix the
>> resolution. Michal, please double check the resolution proposal below so
>> that I didn't miss anything.
>> 
>> https://patchwork.kernel.org/patch/6387631/
>
> Thanks, I think I got the conflict resolution correct, please have a look.

Looks good, thanks for fixing it.

-- 
Kalle Valo
