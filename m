From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH 31/31] timer: Switch to testing for .function instead of .data
Date: Thu, 31 Aug 2017 16:45:37 -0700
Message-ID: <CAKdAkRTSgs+JTKRa2nvcSPD+zQ5OhsLx_aM8WaZyg304QQN3hA@mail.gmail.com>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org> <1504222183-61202-32-git-send-email-keescook@chromium.org>
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
        linux-rdma@vger.kernel.org,
        "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
        intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504222183-61202-32-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 4:29 PM, Kees Cook <keescook@chromium.org> wrote:
> In several places, .data is checked for initialization to gate early
> calls to del_timer_sync(). Checking for .function is equally valid, so
> switch to this in all callers.

Not seeing the rest of patches it is unclear from the patch
description why this is needed/wanted.

Thanks.

-- 
Dmitry
