From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 20/22] sound: pci: avoid string overflow warnings
Date: Tue, 18 Jul 2017 13:52:30 +0200
Message-ID: <CAK8P3a3G+scFLTbJhxNpGEwAw5TG18M27x6zYOGVZY0GUsnpPw@mail.gmail.com>
References: <20170714120720.906842-1-arnd@arndb.de> <20170714120720.906842-21-arnd@arndb.de>
 <s5hinivfbic.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jaroslav Kysela <perex@perex.cz>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        alsa-devel@alsa-project.org,
        "David S . Miller" <davem@davemloft.net>,
        Geliang Tang <geliangtang@gmail.com>,
        "the arch/x86 maintainers" <x86@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Takashi Sakamoto <o-takashi@sakamocchi.jp>,
        linux-scsi <linux-scsi@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5hinivfbic.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 2:28 PM, Takashi Iwai <tiwai@suse.de> wrote:
> On Fri, 14 Jul 2017 14:07:12 +0200,
>
> Thanks for the patch.  I have seen it but ignored, so far, as not sure
> which action is the best.  An alternative solution is to use
> snprintf() blindly, for example.
>
> For mixart, it's even better to drop mgr->shortname[] and longname[]
> assignment.  The shortname is the fixed string, and the longname is
> used only at copying to card->longname, so we can create a string
> there from the scratch.

I've done that now, and tried to be a little smarter with the other
conversions. I also found related problems in ISA drivers after
randconfig testing and fixed those as well.

Sent a 7-patch series now as a replacement.

       Arnd
