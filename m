From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/1] e1000: prevent oops when adapter is being closed and
 reset simultaneously
Date: Fri, 22 Nov 2013 15:03:52 -0800
Message-ID: <CAL3LdT5w5sz8ftm2FBHUT3hajrGZKjwfK5m0WqdcGMTtaMaEGQ@mail.gmail.com>
References: <528F0DB8.7020604@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, zhuyj <zyjzyj2000@gmail.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <528F0DB8.7020604@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 21, 2013 at 11:54 PM, yzhu1 <Yanjun.Zhu@windriver.com> wrote:
> Hi, maintainers
>
> This change is based on a similar change made to e1000e support in
> commit bb9e44d0d0f4 ("e1000e: prevent oops when adapter is being closed
> and reset simultaneously").  The same issue has also been observed
> on the older e1000 cards.
>
> Here, we have increased the RESET_COUNT value to 50 because there are too
> many accesses to e1000 nic on stress tests to e1000 nic, it is not enough
> to set RESET_COUT 25. Experimentation has shown that it is enough to set
> RESET_COUNT 50.
>
> Please help me to merge this patch. Thanks a lot.
>
> Zhu Yanjun

Please remember to actually include the driver maintainer for the
driver your patch is against (i.e. me).

I will add your patch to my queue.

-- 
Cheers,
Jeff
