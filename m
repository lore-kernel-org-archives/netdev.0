From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 00:38:12 +0800
Message-ID: <52601274.5010008@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jianhai luan <jianhai.luan@oracle.com>, david.vrabel@citrix.com,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32109 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757653Ab3JQQi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 12:38:29 -0400
In-Reply-To: <525FC98002000078000FBBB5@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-17 17:26, Jan Beulich wrote:
>> Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond
>> MAX_ULONG/2 in 64-bit will need long long time)
>>
>> I think the gap should be think all environment even now extending 480+.
>> if now fall in the gap,  one timer will be pending and replenish will be
>> in time.  Please run the attachment test program.
> Not sure what this is supposed to tell me. I recognize that there
> are overflow conditions not handled properly, but (a) I have a
> hard time thinking of a sensible guest that sits idle for over 240
> days (host uptime usually isn't even coming close to that due to
> maintenance requirements) and (b) if there is such a sensible
> guest, then I can't see why dealing with one being idle for over
> 480 days should be required too.
>

If the guest contains multiple NICs, that situation probably happens 
when one NIC keeps idle and others work under load. BTW, how do you get 
the 240?

Thanks
Annie
