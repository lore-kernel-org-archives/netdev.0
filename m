From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] timer: Remove meaningless .data/.function assignments
Date: Mon, 09 Oct 2017 18:05:55 -0700 (PDT)
Message-ID: <20171009.180555.71645109792027520.davem@davemloft.net>
References: <20171010001032.GA119829@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org, axboe@fb.com,
 ganesh.krishna@microchip.com, netdev@vger.kernel.org,
 aditya.shankar@microchip.com, tglx@linutronix.de, khc@pm.waw.pl
To: keescook@chromium.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20171010001032.GA119829@beast>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Mon, 9 Oct 2017 17:10:32 -0700

> Several timer users needlessly reset their .function/.data fields during
> their timer callback, but nothing else changes them. Some users do not
> use their .data field at all. Each instance is removed here.
> 
> Cc: Krzysztof Halasa <khc@pm.waw.pl>
> Cc: Aditya Shankar <aditya.shankar@microchip.com>
> Cc: Ganesh Krishna <ganesh.krishna@microchip.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Jens Axboe <axboe@fb.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Cc: devel@driverdev.osuosl.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org> # for staging
> Acked-by: Krzysztof Halasa <khc@pm.waw.pl> # for wan/hdlc*
> Acked-by: Jens Axboe <axboe@kernel.dk> # for amiflop
> ---
> This should go via the timer/core tree, please. It's been acked by each
> of the maintainers. Thanks!

For networking bits:

Acked-by: David S. Miller <davem@davemloft.net>
