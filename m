From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv4 net-next 08/10] netfilter: connlabels: Export setting
 connlabel length
Date: Wed, 19 Aug 2015 13:48:35 -0700
Message-ID: <CALnjE+raW0T3FuJ_Hg9S3LxT+3ZYNaNRfxV+pkZzYaOy_oA4ig@mail.gmail.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
	<1439941188-19293-9-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439941188-19293-9-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2015 at 4:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Add functions to change connlabel length into nf_conntrack_labels.c so
> they may be reused by other modules like OVS and nftables without
> needing to jump through xt_match_check() hoops.
>
> Suggested-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Florian Westphal <fw@strlen.de>
> ---
> v2: Protect connlabel modification with spinlock.
>     Fix reference leak in error case.
>     Style fixups.
> v3: No change.
> v4: Add ack.
> ---
Looks good to me.
