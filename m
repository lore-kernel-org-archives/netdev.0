From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Wed, 13 Jan 2010 07:20:22 +0100
Message-ID: <m2d41eil09.fsf@ssh.synack.fr>
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

> Samir Bellabes wrote:
>> +static const struct nla_policy snet_genl_policy[SNET_A_MAX + 1]
>> +__read_mostly = {
>
> You don't need __read_mostly for const. If I recall correctly, it even
> causes an error with certain compiler or linker versions.

fixed, thanks Patrick

I didn't had errors with (fedora core 11):
gcc (GCC) 4.4.1 20090725 (Red Hat 4.4.1-2)
GNU ld version 2.19.51.0.2-17.fc11 20090204

nor (ubuntu 9.10):
gcc (Ubuntu 4.4.1-4ubuntu8) 4.4.1 
GNU ld (GNU Binutils for Ubuntu) 2.20 (2.20-0ubuntu2)

sam
