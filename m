From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnxt_en: tc: only the function prototypes
 need to be wrapped in #ifdef
Date: Sat, 07 Oct 2017 03:01:03 +0100 (WEST)
Message-ID: <20171007.030103.394881238635414484.davem@davemloft.net>
References: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
        <a58d04f653e79b12c86eaa67f768f4ff64b2a975.1507319311.git.jtoppins@redhat.com>
        <CACKFLik-dU=1bouTiHhREt4p5X=cGQFjz3fAjHn_pLJQm4FJ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jtoppins@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACKFLik-dU=1bouTiHhREt4p5X=cGQFjz3fAjHn_pLJQm4FJ2A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri, 6 Oct 2017 18:27:31 -0700

> On Fri, Oct 6, 2017 at 12:48 PM, Jonathan Toppins <jtoppins@redhat.com> wrote:
>> There is no reason to wrap the data structures inside the ifdef.
> 
> What's so bad about wrapping unused data structures inside #ifdef?
> These structures are only used if CONFIG_BNXT_FLOWER_OFFLOAD is
> defined.

Yeah I agree, this ifdef is actually a good way to trap unintentional
usage of those datastructures so it's doubly best to keep the ifdef.
