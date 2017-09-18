From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V1 net-next 2/6] net: skbuff: Add a field to support
 time based transmission.
Date: Mon, 18 Sep 2017 08:14:45 -0700
Message-ID: <1505747685.29839.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1505719061.git.rcochran@linutronix.de>
         <555939002f1ca9d89b14f30b3579445e4fa628d9.1505719061.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: Richard Cochran <rcochran@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555939002f1ca9d89b14f30b3579445e4fa628d9.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-09-18 at 09:41 +0200, Richard Cochran wrote:
> Signed-off-by: Richard Cochran <rcochran@linutronix.de>
> ---
>  include/linux/skbuff.h | 2 ++
>  1 file changed, 2 insertions(+)

Why skb->tstamp can not be used ?

AFAIK, fact that it might be overwritten by packet captures should not hurt.
