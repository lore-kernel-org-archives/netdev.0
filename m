From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: 3.10-rc1: commit ccdfcc398594 broke uClibc build.
Date: Tue, 9 Jul 2013 10:13:31 +0200
Message-ID: <CAMuHMdUfBkL_YGEJo2VhfVYR99p3EsPHoVjtA+f_cgDEvumXpw@mail.gmail.com>
References: <1368850897.18069.255@driftwood>
	<CAMuHMdX0aP7jm=2vAO=Mg9b-RggynRq+BosvzGfqSRtnyue4+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rob Landley <rob@landley.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdX0aP7jm=2vAO=Mg9b-RggynRq+BosvzGfqSRtnyue4+w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 9, 2013 at 10:02 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> Widening the audience...

Do, linux-net is no more...

> On Sat, May 18, 2013 at 6:21 AM, Rob Landley <rob@landley.net> wrote:
>> The #include <linux/kernel.h> added to include/uapi/linux/netlink.h causes
>> the uClibc build to go:
>>
>> In file included from include/linux/kernel.h:4,
>>                  from include/linux/netlink.h:4,
>>                  from include/linux/rtnetlink.h:5,
>>                  from libc/inet/netlinkaccess.h:27,
>>                  from libc/inet/if_index.c:37:
>> include/linux/sysinfo.h:8: error: expected specifier-qualifier-list before
>> '__kernel_long_t'
>> make: *** [libc/inet/if_index.o] Error 1
>>
>> If I comment out that line, it builds fine. The kernel builds (for my
>> config) either way.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
