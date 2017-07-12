From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Lots of new warnings with gcc-7.1.1
Date: Tue, 11 Jul 2017 20:17:21 -0700
Message-ID: <CA+55aFyKpezj3oHwtBShyf9x-DJNAGQhrq55iVGM42eWKQtP3w@mail.gmail.com>
References: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
 <848b3f21-9516-8a66-e4b3-9056ce38d6f6@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tejun Heo <tj@kernel.org>, Jean Delvare <jdelvare@suse.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "the arch/x86 maintainers" <x86@kernel.org>,
        xen-devel <xen-devel@lists.xenproject.org>,
        linux-block <linux-block@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        IDE-ML <linux-ide@vger.kernel.org>,
        "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <848b3f21-9516-8a66-e4b3-9056ce38d6f6@roeck-us.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2017 at 8:10 PM, Guenter Roeck <linux@roeck-us.net> wrote:
>
> The hwmon warnings are all about supporting no more than 9,999 sensors
> (applesmc) to 999,999,999 sensors (scpi) of a given type.

Yeah, I think that's enough.

> Easy "fix" would be to replace snprintf() with scnprintf(), presumably
> because gcc doesn't know about scnprintf().

If that's the case, I'd prefer just turning off the format-truncation
(but not overflow) warning with '-Wno-format-trunction".

But maybe we can at least start it on a subsystem-by-subsystem basis
after people have verified their own subsusystem?

                  Linus
