From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 3/7] openvswitch: Fix skb leak in ovs_fragment()
Date: Thu, 1 Oct 2015 15:25:26 -0700
Message-ID: <CALnjE+pOhfEr1rHNArxOjXaC35Z-CMLj+BBtK9hzzP_CjR4uaw@mail.gmail.com>
References: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
	<1443732810-38746-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443732810-38746-4-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 1, 2015 at 1:53 PM, Joe Stringer <joestringer@nicira.com> wrote:
> If ovs_fragment() was unable to fragment the skb due to an L2 header
> that exceeds the supported length, skbs would be leaked. Fix the bug.
>
> Fixes: 7f8a436 "openvswitch: Add conntrack action"
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2: Drop if condition, return in success case.
> ---
Acked-by: Pravin B Shelar <pshelar@nicira.com>
