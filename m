From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH 1/1] netdev: broadcom: propagate error code
Date: Sat, 3 Dec 2016 10:50:33 -0800
Message-ID: <CACKFLinpqUstx9+6BfNZK5iNQ4Sf8ktY+E6iAqBNdttz8qqGig@mail.gmail.com>
References: <1480758977-4234-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Prashant Sreedharan <prashant.sreedharan@broadcom.com>,
        Satish Baddipadige <sbaddipa@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Pan Bian <bianpan2016@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480758977-4234-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 3, 2016 at 1:56 AM, Pan Bian <bianpan2016@163.com> wrote:
> Function bnxt_hwrm_stat_ctx_alloc() always returns 0, even if the call
> to _hwrm_send_message() fails. It may be better to propagate the errors
> to the caller of bnxt_hwrm_stat_ctx_alloc().
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188661
>
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>
