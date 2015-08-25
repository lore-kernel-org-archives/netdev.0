From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv5 net-next 09/10] openvswitch: Allow matching on conntrack label
Date: Tue, 25 Aug 2015 13:44:58 -0700
Message-ID: <CALnjE+ra1B=787WBEvn6FV=gvwqEn_k661mFEu_UHSQx+HbQYg@mail.gmail.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
	<1440462740-23358-10-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440462740-23358-10-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 24, 2015 at 5:32 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Allow matching and setting the ct_label field. As with ct_mark, this is
> populated by executing the CT action. The label field may be modified by
> specifying a label and mask nested under the CT action. It is stored as
> metadata attached to the connection. Label modification occurs after
> lookup, and will only persist when the conntrack entry is committed by
> providing the COMMIT flag to the CT action. Labels are currently fixed
> to 128 bits in size.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
