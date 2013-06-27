From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC Patch net-next 1/5] net: introduce generic union inet_addr
Date: Thu, 27 Jun 2013 10:14:30 +0200
Message-ID: <51CBF466.4050705@redhat.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>  <1372315398-19683-2-git-send-email-amwang@redhat.com> <1372318969.24799.70.camel@smile>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372318969.24799.70.camel@smile>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2013 09:42 AM, Andy Shevchenko wrote:
> On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> I was about to answer for the Daniel's patch about %pig.
>
> Daniel, could you resend your patch series to the LKML, since it touches
> lib/vsprintf.c.

Agreed. Will put lkml into CC for the vsprintf change.

> Also, regarding to your patch 2/2, could it be possible to split it to
> two parts: first substitutes SCTP macros not related to IP addresses and
> second one is explicitly targeting against SCTP_DEBUG_PRINTK_IPADDR ?

Well, as Vlad, one of the SCTP maintainers, already went through this patch
and I've already applied the few changes he requested, I'd like not to put
too much burden on yet another round of review, as the rest of the code
stays as is.

> By the way, in some places in 2/2 you didn't change open coded function
> name to the '"%s: ...", __func__, ...'.

Right, but those messages are rather more of generic nature. I went through
all of this in detail, and I think it's okay like that.

> Cong, I don't think is a good idea to update lib/ code and net/ code in
> one patch, since that are logically a bit different. lib/ code sounds
> more common, it's better if it leads separately this series.
