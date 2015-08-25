From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv5 net-next 06/10] openvswitch: Allow matching on conntrack mark
Date: Tue, 25 Aug 2015 13:34:26 -0700
Message-ID: <CALnjE+pPArMNOzzVNTPttSU=UjPFygC6-9KfWpFOqFfREHChHw@mail.gmail.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
	<1440462740-23358-7-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:32969 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497AbbHYUe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:34:27 -0400
Received: by igfj19 with SMTP id j19so21541815igf.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 13:34:27 -0700 (PDT)
In-Reply-To: <1440462740-23358-7-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 5:32 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Allow matching and setting the ct_mark field. As with ct_state and
> ct_zone, these fields are populated when the CT action is executed. To
> write to this field, a value and mask can be specified as a nested
> attribute under the CT action. This data is stored with the conntrack
> entry, and is executed after the lookup occurs for the CT action. The
> conntrack entry itself must be committed using the COMMIT flag in the CT
> action flags for this change to persist.
>
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
