From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RESEND PATCH -net] cpsw/netcp: cpts depends on posix_timers
Date: Wed, 15 Mar 2017 15:55:24 +0100
Message-ID: <CAK8P3a0h3yDRNstN-O4KhSJxPm9RSVvgJt3t=em2JW1KVUfYfw@mail.gmail.com>
References: <20170313165849.1378558-1-arnd@arndb.de> <alpine.LFD.2.20.1703131608100.14436@knanqh.ubzr>
 <CAK8P3a125rioB5Cnoa7nR9Dz_pU5=x7=06_DvXEE-dTpOBiitQ@mail.gmail.com>
 <alpine.LFD.2.20.1703131629570.14436@knanqh.ubzr> <alpine.LFD.2.20.1703131648350.14436@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1703131648350.14436@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 9:51 PM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> On Mon, 13 Mar 2017, Nicolas Pitre wrote:
>
>> So unless I'm mistaken I don't see any problem using "depends on
>> PTP_1588_CLOCK" here.
>
> Furthermore that wouldn't be a first. See for example
> PTP_1588_CLOCK_GIANFAR, PTP_1588_CLOCK_IXP46X, DP83640_PHY, etc.

Ok, I'll give this a few rounds on the randconfig builder and submit it that way
unless I run into problems.

    Arnd
