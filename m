From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [RFC Patch net-next 1/5] net: introduce generic union inet_addr
Date: Thu, 27 Jun 2013 10:42:49 +0300
Message-ID: <1372318969.24799.70.camel@smile>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372315398-19683-2-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote: 
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

I was about to answer for the Daniel's patch about %pig.

Daniel, could you resend your patch series to the LKML, since it touches
lib/vsprintf.c.
Also, regarding to your patch 2/2, could it be possible to split it to
two parts: first substitutes SCTP macros not related to IP addresses and
second one is explicitly targeting against SCTP_DEBUG_PRINTK_IPADDR ?
By the way, in some places in 2/2 you didn't change open coded function
name to the '"%s: ...", __func__, ...'.

Cong, I don't think is a good idea to update lib/ code and net/ code in
one patch, since that are logically a bit different. lib/ code sounds
more common, it's better if it leads separately this series.


-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
