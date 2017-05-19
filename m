From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 00/10] rt2x00: rt2x00: improve calling conventions for
 register accessors
Date: Fri, 19 May 2017 14:20:03 +0200
Message-ID: <CAK8P3a3MvoL=affLZNL7PsbRFFBOFf7eS8cGAg1JzmAsMB=02Q@mail.gmail.com>
References: <20170517144702.1381136-1-arnd@arndb.de> <87r2zl8lvi.fsf@codeaurora.org>
 <CAKR_QVJGxWF8+ZGGn08XiOgpYVGSjwQwqJoP10fY_bjfRg-uzw@mail.gmail.com>
 <CAK8P3a3Y7rCvmJo062-5G07HGiT6x2MtvVV=dQAVBK0AiX0U_A@mail.gmail.com> <CAKR_QVLf5Yn3En2DD4Pwbc2+EKaO9xGB0qU3MWQrNWNjZkx1CA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        David Miller <davem@davemloft.net>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Daniel Golle <daniel@makrotopia.org>,
        Mathias Kresin <dev@kresin.me>,
        Johannes Berg <johannes.berg@intel.com>,
        Serge Vasilugin <vasilugin@yandex.ru>,
        Roman Yeryomin <roman@advem.lv>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jes Sorensen <jes.sorensen@gmail.com>
To: Tom Psyborg <pozega.tomislav@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKR_QVLf5Yn3En2DD4Pwbc2+EKaO9xGB0qU3MWQrNWNjZkx1CA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 19, 2017 at 2:15 PM, Tom Psyborg <pozega.tomislav@gmail.com> wrote:
>
>
> On 19 May 2017 at 08:55, Arnd Bergmann <arnd@arndb.de> wrote:
>>
>>
>> On which base version did you apply my patches? There may be a conflict
>> against patches that are in your tree but not yet in linux-next, as I
>> don't see
>> the warning and also see no reference to rt2800_bbp_read in rt2800lib.h
>>
>>       Arnd
>
>
>
> it's not exactly base version, it is patched comapt-wireless in openwrt that
> i applied your patches to (i had to fix some things manually) but these
> warnings might appear because of recent mt7620 commit:
> https://git.lede-project.org/?p=lede/dangole/staging.git;a=blob_plain;f=package/kernel/mac80211/patches/999-0001-rt2800mmio-use-BBP-register-21-to-reset-MT7620-BBP.patch;hb=f4f0d8efa2d55ada111ddcd502a51041364bd7e5

I suspect you just did an incorrect merge, and left an extra 'static'
in front of the declaration in the header file when you modified the
function prototype.

      Arnd
