From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 31/31] timer: Switch to testing for .function instead of .data
Date: Thu, 31 Aug 2017 16:59:05 -0700
Message-ID: <CAGXu5jK84cN9MdjfzaipD7GN8a37JMfD8X0Em4mk2_aFGuaOUg@mail.gmail.com>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org>
 <1504222183-61202-32-git-send-email-keescook@chromium.org> <CAKdAkRTSgs+JTKRa2nvcSPD+zQ5OhsLx_aM8WaZyg304QQN3hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Gleixner <tglx@linutronix.de>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
        intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <CAKdAkRTSgs+JTKRa2nvcSPD+zQ5OhsLx_aM8WaZyg304QQN3hA@mail.gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 4:45 PM, Dmitry Torokhov
<dmitry.torokhov@gmail.com> wrote:
> On Thu, Aug 31, 2017 at 4:29 PM, Kees Cook <keescook@chromium.org> wrote:
>> In several places, .data is checked for initialization to gate early
>> calls to del_timer_sync(). Checking for .function is equally valid, so
>> switch to this in all callers.
>
> Not seeing the rest of patches it is unclear from the patch
> description why this is needed/wanted.

The CC list would have been really giant, but here is the first patch
and the earlier series list:

https://lkml.org/lkml/2017/8/31/904
https://lkml.org/lkml/2017/8/30/760

tl;dr: We're going to switch all struct timer_list callbacks to get
the timer pointer as the argument instead of from the .data field.
This patch is one step in removing open-coded users of the .data
field.

-Kees

-- 
Kees Cook
Pixel Security
