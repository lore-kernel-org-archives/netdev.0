From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 10:00:36 -0500
Message-ID: <54C11094.2000807@mojatatu.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150122125246.GA4486@salvia> <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:49129 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbAVPAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:00:39 -0500
Received: by mail-ie0-f170.google.com with SMTP id y20so1773778ier.1
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:00:39 -0800 (PST)
In-Reply-To: <20150122140022.GA5674@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 09:00, Pablo Neira Ayuso wrote:

>
> +/* rocker specific action definitions */
> +struct net_flow_action_arg rocker_set_group_id_args[] = {
> +       {
> +               .name = "group_id",
> +               .type = NFL_ACTION_ARG_TYPE_U32,
> +               .value_u32 = 0,
> +       },
>
> that is retrieved via ndo_flow_get_actions and fully exposed to
> userspace.
>

My main concern is along similar lines (I did express it earlier and
I think Jiri chimed in as well).
The API exposes direct access to hardware. I am sure this was a result
of trying to replace the ethtool interface (which was primitive).
By providing vendors direct access to the hardware - they do not need
to use any traditional Linux tooling/APIs. I see this as a gaping hole
for vendor SDKs with their own definitions of their own hardware that
doesnt work with anyone else. i.e it seems to standardize proprietary
interfaces. Maybe thats what Pablo is alluding to.
Interfacing tc or nftables (or pick your favorite linux tool here) would
be preferable.

cheers,
jamal
