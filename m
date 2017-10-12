From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: usb/net/rt2x00: warning in rt2800_eeprom_word_index
Date: Thu, 12 Oct 2017 09:25:30 +0200
Message-ID: <20171012072529.GB2686@redhat.com>
References: <CAAeHK+yUNrrNU3Jqrfs7XAT809eyF4nv673cSL8RppbLrDtWNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+yUNrrNU3Jqrfs7XAT809eyF4nv673cSL8RppbLrDtWNA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Mon, Oct 09, 2017 at 07:50:53PM +0200, Andrey Konovalov wrote:
> I've got the following report while fuzzing the kernel with syzkaller.
> 
> On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).
> 
> I'm not sure whether this is a bug in the driver, or just a way to
> report misbehaving device. In the latter case this shouldn't be a
> WARN() call, since WARN() means bug in the kernel.

This is about wrong EEPROM, which reported 3 tx streams on
non 3 antenna device. I think WARN() is justified and thanks
to the call trace I was actually able to to understand what
happened.

In general I do not think WARN() only means a kernel bug, it 
can be F/W or H/W bug too.

Thanks
Stanislaw
