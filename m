From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net 1/7] b44: Initialize 64-bit stats seqcount
Date: Tue, 1 Aug 2017 13:41:47 -0700
Message-ID: <CACKFLineNFnJc7T_pS2v_kVDb6yXoOSExtMjzvndr7b+Hp8UvQ@mail.gmail.com>
References: <20170801191113.8754-1-f.fainelli@gmail.com> <20170801191113.8754-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, edumazet@google.com,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801191113.8754-2-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 1, 2017 at 12:11 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
> lockdep splat indicating this seqcount is not correctly initialized, fix
> that.
>
> Fixes: eeda8585522b ("b44: add 64 bit stats")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>

Thanks.
