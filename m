From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v2 00/10] rt2x00: rt2x00: improve calling conventions for
 register accessors
Date: Fri, 19 May 2017 08:55:21 +0200
Message-ID: <CAK8P3a3Y7rCvmJo062-5G07HGiT6x2MtvVV=dQAVBK0AiX0U_A@mail.gmail.com>
References: <20170517144702.1381136-1-arnd@arndb.de> <87r2zl8lvi.fsf@codeaurora.org>
 <CAKR_QVJGxWF8+ZGGn08XiOgpYVGSjwQwqJoP10fY_bjfRg-uzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Daniel Golle <daniel-g5gK2j5usbvCyp4qypjU+w@public.gmane.org>,
        Mathias Kresin <dev-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Serge Vasilugin <vasilugin-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>,
        Roman Yeryomin <roman-9zmcapQ0v8Q@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Tom Psyborg <pozega.tomislav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKR_QVJGxWF8+ZGGn08XiOgpYVGSjwQwqJoP10fY_bjfRg-uzw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 19, 2017 at 8:44 AM, Tom Psyborg <pozega.tomislav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> warning: 'rt2800_bbp_read' used but never defined
>  static u8 rt2800_bbp_read(struct rt2x00_dev *rt2x00dev,
>            ^
> /home/ubuntu/Music/openwrt/build_dir/target-mipsel_24kc_musl-1.1.16/linux-ramips_mt7620/compat-wireless-2016-05-12/drivers/net/wireless/ralink/rt2x00/rt2800lib.h:262:13:
> warning: 'rt2800_bbp_write' used but never defined
>  static void rt2800_bbp_write(struct rt2x00_dev *rt2x00dev,
>              ^
>   CC [M]
> /home/ubuntu/Music/openwrt/build_dir/target-mipsel_24kc_musl-1.1.16/linux-ramips_mt7620/compat-wireless-2016-05-12/drivers/net/wireless/ralink/rt2x00/rt2800pci.o
> In file included from
> /home/ubuntu/Music/openwrt/build_dir/target-mipsel_24kc_musl-1.1.16/linux-ramips_mt7620/compat-wireless-2016-05-12/drivers/net/wireless/ralink/rt2x00/rt2800pci.c:43:0:
> /home/ubuntu/Music/openwrt/build_dir/target-mipsel_24kc_musl-1.1.16/linux-ramips_mt7620/compat-wireless-2016-05-12/drivers/net/wireless/ralink/rt2x00/rt2800lib.h:259:11:
> warning: 'rt2800_bbp_read' declared 'static' but never defined
> [-Wunused-function]
>  static u8 rt2800_bbp_read(struct rt2x00_dev *rt2x00dev,
>            ^

On which base version did you apply my patches? There may be a conflict
against patches that are in your tree but not yet in linux-next, as I don't see
the warning and also see no reference to rt2800_bbp_read in rt2800lib.h

      Arnd
