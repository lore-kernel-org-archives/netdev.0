From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH net-next 2/2] bnxt_en: define sriov_lock unconditionally
Date: Wed, 26 Jul 2017 16:24:41 +0530
Message-ID: <CAKvpyk3hyoAj0w9v1ZDfBs=8s4c=3kbDT8ZpDEUTb1yJnRvzuA@mail.gmail.com>
References: <20170725153046.44726-1-arnd@arndb.de> <20170725153046.44726-2-arnd@arndb.de>
 <CACKFLimnZx7v9jV7v27XMP62BWG577D8=zkTijQYa6Pi1Ct7yA@mail.gmail.com> <CAK8P3a3UBfg6=GJ5UKEENnN-qoFuxaO4yo2Lqy65gN0zP4Nw-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Michael Chan <michael.chan@broadcom.com>,
        "David S. Miller" <davem@davemloft.net>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Deepak Khungar <deepak.khungar@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3UBfg6=GJ5UKEENnN-qoFuxaO4yo2Lqy65gN0zP4Nw-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2017 at 2:35 PM, Arnd Bergmann <arnd@arndb.de> wrote:
[...]
>> Sathya already sent 3 patches to fix some of these issues.  But I need
>> to rework one of his patch and resend.
>
> Ok, thanks. I just ran into one more issue, and don't know if that's included
> as well. If not, please also add the patch below (or fold it into the one
> that adds the switchdev dependency to the ethernet driver):
>
> 8<----------
> Subject: [PATCH] RDMA/bnxt_re: add NET_SWITCHDEV dependency
>
> The rdma side of BNXT enables the ethernet driver and has a list
> of its dependencies. However, the ethernet driver now also depends
> on NET_SWITCHDEV, so we have to add that dependency for both:

Arnd, after the patch "bnxt_en: use SWITCHDEV_SET_OPS() for setting
vf_rep_switchdev_ops" the bnxt_en driver doesn't need an explicit
NET_SWITCHDEV dependency. So, the bnxt_re driver shouldn't need one
either. Are you still seeing the bnxt_re issue even after pulling the
above patch??
