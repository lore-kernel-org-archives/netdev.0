From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC v2 3/7] net: netfilter conntrack - add per-net
	functionality for SCTP protocol
Date: Mon, 16 Mar 2009 18:46:20 +0300
Message-ID: <20090316154620.GA7551@localhost>
References: <20090311205706.141086138@gmail.com> <20090311210817.384140456@gmail.com> <49BE71AF.8050200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, daniel.lezcano@free.fr,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49BE71AF.8050200@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Patrick McHardy - Mon, Mar 16, 2009 at 04:35:11PM +0100]
...
> +#define ___PERNET_TO_DAT(i, j) \
>> +	sn->compat_sysctl_table[i].data = &sn->sctp_timeouts[j]
>> +
>> +	___PERNET_TO_DAT(0, SCTP_CONNTRACK_CLOSED);
>> +	___PERNET_TO_DAT(1, SCTP_CONNTRACK_COOKIE_WAIT);
>> +	___PERNET_TO_DAT(2, SCTP_CONNTRACK_COOKIE_ECHOED);
>> +	___PERNET_TO_DAT(3, SCTP_CONNTRACK_ESTABLISHED);
>> +	___PERNET_TO_DAT(4, SCTP_CONNTRACK_SHUTDOWN_SENT);
>> +	___PERNET_TO_DAT(5, SCTP_CONNTRACK_SHUTDOWN_RECD);
>> +	___PERNET_TO_DAT(6, SCTP_CONNTRACK_SHUTDOWN_ACK_SENT);
>> +
>> +#undef ___PERNET_TO_DAT
>
> This is really ugly and is somewhat risky since those magic offsets need
> to be kept in sync. Any chance (I don't have a suggestion currently) to
> do this in a nicer way?
>

Give me some time Patrick, will try. Actually initial idea
of these macros was to eliminate 'possible' problems caused
by for (;;) form (enum could be rearranged and we will fail
silently). So I guess the some 'new' form of template would
help (instead of current "ctrl table as a templae"). So
will return with new proposal. Thanks for review!

	- Cyrill -
