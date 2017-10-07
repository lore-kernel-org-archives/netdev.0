From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 2/2] bnxt_en: tc: only the function prototypes
 need to be wrapped in #ifdef
Date: Fri, 6 Oct 2017 18:27:31 -0700
Message-ID: <CACKFLik-dU=1bouTiHhREt4p5X=cGQFjz3fAjHn_pLJQm4FJ2A@mail.gmail.com>
References: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
 <a58d04f653e79b12c86eaa67f768f4ff64b2a975.1507319311.git.jtoppins@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Jonathan Toppins <jtoppins@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a58d04f653e79b12c86eaa67f768f4ff64b2a975.1507319311.git.jtoppins@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 6, 2017 at 12:48 PM, Jonathan Toppins <jtoppins@redhat.com> wrote:
> There is no reason to wrap the data structures inside the ifdef.

What's so bad about wrapping unused data structures inside #ifdef?
These structures are only used if CONFIG_BNXT_FLOWER_OFFLOAD is
defined.
