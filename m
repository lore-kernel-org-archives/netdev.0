From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH net-next 1/5] sctp: Bring SCTP_MAXSEG socket option into
 ietf API extension compliance
Date: Fri, 26 Dec 2008 12:04:14 -0500
Message-ID: <49550E8E.6030607@hp.com>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>	<1229737672-28328-3-git-send-email-vladislav.yasevich@hp.com> <20081225.165625.248148862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:9081 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbYLZRFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 12:05:15 -0500
In-Reply-To: <20081225.165625.248148862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 19 Dec 2008 20:47:48 -0500
> 
>> From: Wei Yongjun <yjwei@cn.fujitsu.com>
>>
>> Brings maxseg socket option set/get into line with the latest ietf socket
>> extensions API draft, while maintaining backwards compatibility.
>>
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> Applied.  But I really dislike this scheme used by the compat code.
> Half-way initializing a structure and then depending upon the logic in
> the rest of the function to make sure the rest of the struct (the
> uninitialized part) is never accessed?
> 
> Give me a break, programming, auditing, and bug fixing is hard enough
> as it is without sloppy code like this.

Yes, it sucks but the since the draft keeps breaking the ABI between revisions,
it leaves us a between a rock (no support) and a hard place (crappy code).

-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

