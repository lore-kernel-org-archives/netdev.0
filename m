From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: netinet/ip.h and DSCP
Date: Mon, 12 Oct 2009 11:20:34 -0700
Message-ID: <4AD37372.8090401@redfish-solutions.com>
References: <4AC68714.5080909@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:50377 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757511AbZJLSVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 14:21:15 -0400
Received: from [192.168.10.7] (builder.redfish-solutions.com [192.168.10.7])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.3/8.14.3) with ESMTP id n9CIKYb7010092
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 12:20:38 -0600
In-Reply-To: <4AC68714.5080909@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since linux-net doesn't seem to be the right forum...


On 10/02/2009 04:04 PM, Philip A. Prindeville wrote:
> Is there a reason that /usr/include/netinet/ip.h only contains
> definitions for ToS (precedence-based) markings?
>
> RFCs 2597/2598 have been out a *long* time... why is Linux so far behind
> the learning curve?
>
> We're discussing (at least here in the US) net neutrality...  but if
> we're not marking our traffic the way we want it carried *anyway*, don't
> we deserve what we get if the carriers reshape our traffic by their own
> rules?
>
> Should there be definitions in netinet/ip.h like:
>
> #define IPTOS_DSCP_MASK		0xd0
> #define IPTOS_DSCP(x)		((x) & IPTOS_DSCP_MASK)
> #define IPTOS_DSCP_AF11		0x28
> #define IPTOS_DSCP_AF12		0x30
> #define IPTOS_DSCP_AF13		0x38
> #define IPTOS_DSCP_AF21		0x48
> #define IPTOS_DSCP_AF22		0x50
> #define IPTOS_DSCP_AF23		0x58
> #define IPTOS_DSCP_AF31		0x68
> #define IPTOS_DSCP_AF32		0x70
> #define IPTOS_DSCP_AF33		0x78
> #define IPTOS_DSCP_AF41		0x88
> #define IPTOS_DSCP_AF42		0x90
> #define IPTOS_DSCP_AF43		0x98
> #define IPTOS_DSCP_EF		0xb8
>
>
> Should be simple enough, right?
>
> Thanks,
>
> -Philip
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

