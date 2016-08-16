From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: linux-next: Tree for Aug 16 (mellanox/mlx5 & sound/oss/)
Date: Tue, 16 Aug 2016 19:54:37 +0300
Message-ID: <CALzJLG8XOgEOTeQJqjdqHD21azfoVa7RTgKJG9UWUE11cUJRZQ@mail.gmail.com>
References: <20160816140121.5b89f2a0@canb.auug.org.au> <c5f1449f-b1fb-37be-71c1-85691d34994e@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	moderated for non-subscribers <alsa-devel@alsa-project.org>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c5f1449f-b1fb-37be-71c1-85691d34994e@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 16, 2016 at 6:26 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 08/15/16 21:01, Stephen Rothwell wrote:
>> Hi all,
>>
>> Changes since 20160815:
>>
>
> on i386:
>
> sound/built-in.o:(.data+0x5c): multiple definition of `dev_list'
> drivers/built-in.o:(.data+0x6aee8): first defined here
> ld: Warning: size of symbol `dev_list' changed from 8 in drivers/built-in.o to 16 in sound/built-in.o
>
>
> sound/ is an old oss driver (soundcard.c):
>
> struct oss_minor_dev {
>         unsigned short minor;
>         unsigned int enabled;
> } dev_list[] = {
>         { SND_DEV_DSP16 },
>         { SND_DEV_AUDIO },
> };
>
> =====
>
> drivers/ is net/ethernet/mellanox/mlx5/core/mlx5_core.h:
>
> extern struct list_head dev_list;
>

Hi Randy,

We will have to fix this in mlx5 driver.

Thanks,
Saeed.

>
>
>
> --
> ~Randy
