From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 0/4] net-next: mediatek: IRQ cleanups, fixes and grouping
Date: Thu, 16 Jun 2016 11:51:34 +0200
Message-ID: <576276A6.6040904@iogearbox.net>
References: <1466002730-58476-1-git-send-email-john@phrozen.org> <20160615.222050.2210130284846212716.davem@davemloft.net> <5dbb935d-2d9a-48fe-79c7-8e8f57b27678@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	keyhaede@gmail.com, linux-kernel@vger.kernel.org, nbd@nbd.name
To: John Crispin <john@phrozen.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5dbb935d-2d9a-48fe-79c7-8e8f57b27678@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/16/2016 11:44 AM, John Crispin wrote:
> On 16/06/2016 07:20, David Miller wrote:
>> From: John Crispin <john@phrozen.org>
>> Date: Wed, 15 Jun 2016 16:58:46 +0200
>>
>>> This series contains 2 small code cleanups that are leftovers from the
>>> MIPS support. There is also a small fix that adds proper locking to the
>>> code accessing the IRQ registers. Without this fix we saw deadlocks caused
>>> by the last patch of the series, which adds IRQ grouping. The grouping
>>> feature allows us to use different IRQs for TX and RX. By doing so we can
>>> use affinity to let the SoC handle the IRQs on different cores.
>>
>> This patch series doesn't apply cleanly to the net-next tree, I get rejects
>> on patch #4.
>
> it depends on the series with the 11 fixes that i sent last week which
> is however in the net tree and not the next tree (i also still had the
> DQL hack in my tree). if i resend this at the start of the next rc1
> would you merge it into the net tree so that it becomes part of v4.8 ?

Well, it would rather require a merge of -net into -net-next then. But
that would be useful indeed.

Cheers,
Daniel
