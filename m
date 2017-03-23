From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH V8 1/3] irq: Add flags to request_percpu_irq function
Date: Thu, 23 Mar 2017 11:34:21 -0700
Message-ID: <c025cd44-c8a2-1236-803a-5dc39315f2e3@synopsys.com>
References: <1490290924-12958-1-git-send-email-daniel.lezcano@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>,
        "linux-samsung-soc@vger.kernel.org"
        <linux-samsung-soc@vger.kernel.org>,
        "vincent.guittot@linaro.org" <vincent.guittot@linaro.org>,
        "kernel@stlinux.com" <kernel@stlinux.com>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "rafael@kernel.org" <rafael@kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Daniel Lezcano <daniel.lezcano@linaro.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490290924-12958-1-git-send-email-daniel.lezcano@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/23/2017 10:42 AM, Daniel Lezcano wrote:
> In the next changes, we track the interrupts but we discard the timers as
> that does not make sense. The next interrupt on a timer is predictable.
>
> But, the API request_percpu_irq does not allow to pass a flag, hence specifying
> if the interrupt type is a timer.
>
> Solve this by passing a 'flags' parameter to the function and change all the
> callers to pass IRQF_TIMER when the interrupt is a timer interrupt, zero
> otherwise.
>
> For now, in order to prevent a misusage of this parameter, only the IRQF_TIMER
> flag is a valid parameter to be passed to the request_percpu_irq function.
>
> Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>

Acked-by: Vineet Gupta <vgupta@synopsys.com>   # for arch/arc, arc_timer bits
