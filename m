From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] net: can: Convert timers to use timer_setup()
Date: Mon, 9 Oct 2017 11:09:21 -0700
Message-ID: <CAGXu5jKcQ0ez7dEma5fJv3DjWABAoEm+9P_G6aMcdBv6MHnsdQ@mail.gmail.com>
References: <20171005005126.GA23416@beast> <04d30a39-3e88-e46b-ad94-686da16e571e@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <04d30a39-3e88-e46b-ad94-686da16e571e@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 9, 2017 at 10:53 AM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> On 10/05/2017 02:51 AM, Kees Cook wrote:
>> In preparation for unconditionally passing the struct timer_list pointer to
>> all timer callbacks, switch to using the new timer_setup() and from_timer()
>> to pass the timer pointer explicitly.
>>
>> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
>> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: linux-can@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>> This requires commit 686fef928bba ("timer: Prepare to change timer
>> callback argument type") in v4.14-rc3, but should be otherwise
>> stand-alone.
>
> Are you taking the patch or should I apply it?
>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

If you have -rc3 in your tree, please take it. If you want the timers
tree to carry it instead, we can do that too.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security
