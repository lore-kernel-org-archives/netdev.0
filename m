From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v2] p54: don't unregister leds when they are not initialized
Date: Tue, 26 Sep 2017 18:53:36 +0200
Message-ID: <1968721.UFOTox51jp@debian64>
References: <17c60ebcc8ce7f20de41a55087d24dfdfca09c67.1506438620.git.andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17c60ebcc8ce7f20de41a55087d24dfdfca09c67.1506438620.git.andreyknvl@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, September 26, 2017 5:11:33 PM CEST Andrey Konovalov wrote:
> ieee80211_register_hw() in p54_register_common() may fail and leds won't
> get initialized. Currently p54_unregister_common() doesn't check that and
> always calls p54_unregister_leds(). The fix is to check priv->registered
> flag before calling p54_unregister_leds().
> 
> Found by syzkaller.
> 
> [...]
>  process_scheduled_works kernel/workqueue.c:2179
>  worker_thread+0xb2b/0x1850 kernel/workqueue.c:2255
>  kthread+0x3a1/0x470 kernel/kthread.c:231
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Cc: stable@vger.kernel.org
Acked-by: Christian Lamparter <chunkeey@googlemail.com>

Thanks for making the patch too!
