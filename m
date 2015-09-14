From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: Re: [PATCH] Remove #ifdef CONFIG_64BIT from all asm-generic/fcntl.h
Date: Mon, 14 Sep 2015 15:50:12 -0700 (PDT)
Message-ID: <55f74f24.a2eb420a.57553.fffff8c5@mx.google.com>
References: <18247.1441883885@warthog.procyon.org.uk>
Cc: dhowells@redhat.com
To: dhowells@redhat.com
Return-path: <linux-arch-owner@vger.kernel.org>
CC: arnd@arndb.de
CC: 3chas3@gmail.com
CC: hpa@zytor.com
CC: mingo@redhat.com
CC: plagnioj@jcrosoft.com
CC: jikos@kernel.org
CC: linux-api@vger.kernel.org
CC: linux-arch@vger.kernel.org
CC: linux-atm-general@lists.sourceforge.net
CC: linux-fbdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
CC: tglx@linutronix.de
CC: tomi.valkeinen@ti.com
CC: x86@kernel.org
In-Reply-To: <18247.1441883885@warthog.procyon.org.uk>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Sep 2015 04:18:05 PDT (-0700), dhowells@redhat.com wrote:
> David Howells <dhowells@redhat.com> wrote:
>
>> Rather than iterating through all the rest of your patches and saying the same
>> thing, if there's something in a UAPI header that needs wrapping in __KERNEL__
>> to exclude it from userspace's use, then it should be transferred to the
>> non-UAPI variant of that header (which should #include the UAPI variant).
>
> I should mention that there is the odd case where this is difficult to
> achieve.  See include/uapi/linux/acct.h for an example...

OK, sorry about that.  I'm submitting a v3 that should fix these
problems.
