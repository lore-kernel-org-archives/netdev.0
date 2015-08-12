From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net-next 01/10] openvswitch: Serialize acts with
 original netlink len
Date: Wed, 12 Aug 2015 14:34:45 -0700
Message-ID: <CALnjE+q1kHpEcYvYyh82G+E74zON13521ji0A4pVZ8eVfaBwpA@mail.gmail.com>
References: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
	<1439333961-24474-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34947 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbbHLVeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:34:46 -0400
Received: by igbjg10 with SMTP id jg10so51922446igb.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 14:34:46 -0700 (PDT)
In-Reply-To: <1439333961-24474-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 3:59 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, we used the kernel-internal netlink actions length to
> calculate the size of messages to serialize back to userspace.
> However,the sw_flow_actions may not be formatted exactly the same as the
> actions on the wire, so store the original actions length when
> de-serializing and re-use the original length when serializing.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
