From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Wed, 13 Jan 2010 06:36:21 +0100
Message-ID: <4B4D5BD5.4090903@trash.net>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>	<1262437456-24476-8-git-send-email-sam@synack.fr>	<4B420464.3040301@trash.net> <m2vdf6iq6p.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m2vdf6iq6p.fsf@ssh.synack.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>> Samir Bellabes wrote:
>>> +++ b/security/snet/include/snet_netlink.h
>>> +	SNET_A_VERSION,		/* (NLA_U32) the snet protocol version	*/
>> You're using this to check for a "compliant protocol version" below.
>> This shouldn't be needed as any protocol changes need to be done
>> in a compatible fashion.
> 
> what if userspace lib is using a old protocol version ? kernel and
> userspace will use incompatible protocol, which may result in errors.

Any protocol changes need to be done in a compatible fashion once
this is in the upstream kernel, so that case should never happen.

> The idea of this 'version' mecanism is to prevent such
> incompatibilities, even if the userspace is (un)volontary not using the
> good library (which may be the one tagged in the same time as the kernel
> running)
