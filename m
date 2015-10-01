From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 6/7] openvswitch: Extend ct_state match field to 32 bits
Date: Wed, 30 Sep 2015 17:31:53 -0700
Message-ID: <CALnjE+paYkSJDerTOkw+E+CzGMMGc+UnS6+hx_-uFFCTkv3oKA@mail.gmail.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
	<1443566380-22640-7-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443566380-22640-7-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 29, 2015 at 3:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
> The ct_state field was initially added as an 8-bit field, however six of
> the bits are already being used and use cases are already starting to
> appear that may push the limits of this field. This patch extends the
> field to 32 bits while retaining the internal representation of 8 bits.
> This should cover forward compatibility of the ABI for the foreseeable
> future.
>
> This patch also reorders the OVS_CS_F_* bits to be sequential.
>
> Suggested-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>
