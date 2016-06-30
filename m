From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net] net_sched: fix mirrored packets checksum
Date: Fri, 01 Jul 2016 01:11:12 +0200
Message-ID: <5775A710.9010105@iogearbox.net>
References: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com> <57757823.4090000@iogearbox.net> <CAM_iQpXtOr+AD2_q1E_dZm8MmLFAhdqPb6-_3ChgCr38gKi0yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <tom@herbertland.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59469 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbcF3XLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:11:14 -0400
In-Reply-To: <CAM_iQpXtOr+AD2_q1E_dZm8MmLFAhdqPb6-_3ChgCr38gKi0yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2016 12:42 AM, Cong Wang wrote:
> On Thu, Jun 30, 2016 at 12:50 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>
>> Maybe makes sense to move skb_push_rcsum() but /also/ skb_pull_rcsum()
>> to the header then? Both seem similarly small at least (could be split
>> f.e into two patches then, first for the move, second for the actual fix).
>
> No objection from me. Please feel free to send a patch. ;)

Shrug, I actually meant this as feedback to your patch, since you move that
helper and not as a note to myself. ;)

Thanks,
Daniel
