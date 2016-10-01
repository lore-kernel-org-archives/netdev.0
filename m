From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] realtek: rtl8xxxu: Use const init arrays
Date: Sat, 01 Oct 2016 16:32:17 -0400
Message-ID: <wrfjponj4xpq.fsf@redhat.com>
References: <459bf15427d92cd052fb2fe080438fd97a8a6cd8.1475343483.git.joe@perches.com>
        <wrfj37kf6gvd.fsf@redhat.com> <1475352058.1996.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475352058.1996.1.camel@perches.com> (Joe Perches's message of
        "Sat, 01 Oct 2016 13:00:58 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:
> On Sat, 2016-10-01 at 14:53 -0400, Jes Sorensen wrote:
>> Joe Perches <joe@perches.com> writes:
>> > Make the init arrays const to reduce data.
>> > $ size drivers/net/wireless/realtek/rtl8xxxu/built-in.o*
>> > (allyesconfig: x86-32)
>> >    text	   data	    bss	    dec	    hex	filename
>> >   80107 13651 58 93816 16e78
>> > drivers/net/wireless/realtek/rtl8xxxu/built-in.o.new
>> >   65303 28435 58 93796 16e64
>> > drivers/net/wireless/realtek/rtl8xxxu/built-in.o.old
>> In total you grow the kernel by 20 bytes. You reduce the data segment
>> substantially while growing the text segment instead.
>
> No, not really.   The alignment boundaries move a bit for
> this particular compilation.  It could go the other way for
> a different compiler version or set of CONFIG options.
>
> What's important is multiple pages of .data move to .rodata.

Your output shows it moving to the text segment - if it's in a different
segment, eg. rodata, you should use output demonstrating that to justify
the change.

Jes
