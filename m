From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 05/18] net, bluetooth: convert rfcomm_dlc.refcnt from
 atomic_t to refcount_t
Date: Mon, 27 Mar 2017 16:05:34 +0200
Message-ID: <54BFC171-C8E2-47BB-811D-6E9832246256@holtmann.org>
References: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
 <1489749179-12063-6-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-decnet-user@lists.sourceforge.net,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, 3chas3@gmail.com,
        ralf@linux-mips.org, stephen@networkplumber.org,
        jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Johan Hedberg <johan.hedberg@gmail.com>, peterz@infradead.org,
        keescook@chromium.org, Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: Elena Reshetova <elena.reshetova@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489749179-12063-6-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Elena,

> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>
> ---
> include/net/bluetooth/rfcomm.h | 8 +++++---
> net/bluetooth/rfcomm/core.c    | 4 ++--
> 2 files changed, 7 insertions(+), 5 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
