From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/7] secid reconciliation-v02: Enforcement for SELinux
Date: Wed, 20 Sep 2006 18:46:00 -0400
Message-ID: <4511C4A8.2090709@hp.com>
References: <36282A1733C57546BE392885C061859201573267@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:41417 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S932433AbWITWqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 18:46:02 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C061859201573267@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>>+static int selinux_skb_policy_check(struct sk_buff *skb, 
>>
>>unsigned short
>>
>>>family) +{
>>>+	u32 xfrm_sid, trans_sid;
>>>+	int err;
>>>+
>>>+	if (selinux_compat_net)
>>>+		return 1;
>>>+
>>>+	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
>>>+	BUG_ON(err);
>>
>>First, any reason against including the "struct sock *" in 
>>the LSM hook?  At a 
>>quick glance it looks like it is available at each place 
>>security_skb_policy_check() is invoked?  If there are no 
>>objections I would 
>>like to see it included in the hook.
>  
> There's no sock available (NULL) for forward, no-sock, time-wait cases, etc.

... which would be why I should have taken a closer look :)

> What you are trying to accomplish with the sock here anyway?

Actually this is no longer an issue because of something else - you can
ignore this now.

-- 
paul moore
linux security @ hp
