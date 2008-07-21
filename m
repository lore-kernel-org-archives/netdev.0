From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/16] mib: finish with ipv4 mibs netnsization
Date: Mon, 21 Jul 2008 21:38:53 +0400
Message-ID: <4884C9AD.4040608@openvz.org>
References: <487F46CD.7090103@openvz.org> <20080718.040925.261545164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58116 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbYGURjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 13:39:07 -0400
In-Reply-To: <20080718.040925.261545164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Thu, 17 Jul 2008 17:19:09 +0400
> 
>> This is the notorious "finalizing set" - after this all the ipv4
>> stats are isolated from each other. The ipv6, dccp and sctp I
>> touched with previous sets deserve special handling and will be
>> done in 2.6.28
>>
>> No *new* stuff for 2.6.27 from me, thank you Dave for your patience :)
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> All applied, thanks Pavel.
> 
> I keep hearing noises that some day sysfs+ns will work, is that something
> we'll see in 2.6.27 possibly?  

Unfortunately not in 2.6.27 :( Eric send sysfs-for-namespaces patchset
2 or 3 weeks ago, but Greg was going for vacation that time.

> That would help my own build validation and testing of changes.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

