From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Wed, 23 Oct 2013 16:02:14 +0800
Message-ID: <52678286.6000802@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com> <52601274.5010008@oracle.com> <526102DE02000078000FBFBB@nat28.tlf.novell.com> <5260EDD8.4020608@oracle.com> <52610CD202000078000FC00B@nat28.tlf.novell.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7396@saturn3.aculab.com> <20131018112417.GA20185@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Beulich <JBeulich@suse.com>, annie li <annie.li@oracle.com>,
	david.vrabel@citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48275 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab3JWICj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 04:02:39 -0400
In-Reply-To: <20131018112417.GA20185@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-18 19:24, Wei Liu wrote:
> On Fri, Oct 18, 2013 at 09:40:33AM +0100, David Laight wrote:
>>>> My understanding is this patch does not simply double the span, it is
>>>> just stricter than the original one. Please check my previous comments,
>>>> I paste it here.
>>> No, the code (on a 32-bit arch) just _can't_ handle jiffies differences
>>> beyond 2^32, no matter how cleverly you use the respective macros.
>>> All arithmetic there is done modulo 2^32.
>> I haven't followed this discussion very closely but it might be possible
>> to arrange that the 'incorrect lack of credit' only occurs for a few
>> seconds every time 'jiffies' wraps - instead of half of the time.
>> Then you'd have to be extremely unlucky to hit the timing window.
>>
> As I understand it, this is the idea of this patch -- to narrow down the
> timing window.
Jan,  do you agree the idea or have better suggestion to me.

Thanks,
Jason
>
> Wei.
>
>> 	David
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
