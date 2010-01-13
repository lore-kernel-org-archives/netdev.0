From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Wed, 13 Jan 2010 05:41:20 +0100
Message-ID: <m2my0iiplb.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> +atomic_t snet_nl_seq = ATOMIC_INIT(0);
>> +static uint32_t snet_nl_pid;
>> +static struct genl_family snet_genl_family;
>> +atomic_t snet_num_listeners = ATOMIC_INIT(0);
>
> The num_listeners seem to be redundant as you only support a
> single listener anyways, whose presence is indicated by
> snet_nl_pid != 0.

Actually, I may want to support multiple listeners, or simultaneous
communication with userspace, as we may want to listen for event and
reply for verdict in the same time as adding or deleting events.
I will fix this mecanism.

thanks Patrick,
sam
