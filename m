From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Mon, 28 Nov 2016 16:33:11 +0100
Message-ID: <5a9748bb-26ec-b97a-1e98-582b760024f7@marvell.com>
References: <20161123105125.GA26394@amd>
 <f14255ee-7fa8-afef-23ec-fc4f9a74eec8@marvell.com>
 <20161128.095431.856183735501262965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <pavel@ucw.cz>, <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128.095431.856183735501262965.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 28.11.2016 15:54, David Miller wrote:
> From: Lino Sanfilippo <lsanfil@marvell.com>
> Date: Mon, 28 Nov 2016 14:07:51 +0100
>
>> Calling skb_orphan() in the xmit handler made this issue disappear.
>
> This is not the way to handle this problem.
>

I agree, its not a clean solution. But if the use of skb_orphan makes the delays
disappear, it can at least be a hint that socket queue limits are involved.

Regards,
Lino
