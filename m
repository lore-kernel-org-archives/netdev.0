From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Mon, 28 Nov 2016 18:01:10 +0100
Message-ID: <279bb203-486f-7086-e232-ed3e1cb0af2f@marvell.com>
References: <20161128.095431.856183735501262965.davem@davemloft.net>
 <1480347103.18162.58.camel@edumazet-glaptop3.roam.corp.google.com>
 <920b1148-a77d-0b69-01b0-b14bcbdf8648@marvell.com>
 <20161128.113031.964579744326063048.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <pavel@ucw.cz>, <peppe.cavallaro@st.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128.113031.964579744326063048.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 28.11.2016 17:30, David Miller wrote:
> From: Lino Sanfilippo <lsanfil@marvell.com>
> Date: Mon, 28 Nov 2016 16:57:35 +0100
>
>> I wonder if the best fix would be indeed to deactivate irq coalescing
>> completely.
>> Does it make any sense at all to use it if a driver uses NAPI already?
>
> It absolutely does make sense, when it is implemented and functions
> properly.
>

Interesting. I always thought both (NAPI and irq coalescing) are essentially doing the same thing only
one time in software and one time with hw support. Did I misunderstand NAPI?

Regards,
Lino
