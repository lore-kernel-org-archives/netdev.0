From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [BUG]  TIPC handling of -ERESTARTSYS in connect()
Date: Tue, 04 Sep 2012 08:54:23 -0600
Message-ID: <5046161F.8070703@genband.com>
References: <503F84CF.208@genband.com> <504085D9.3010907@windriver.com> <5040D3C4.2010308@genband.com> <5040D5D9.4040802@genband.com> <504420FD.4030908@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og121.obsmtp.com ([64.18.2.20]:47678 "EHLO
	exprod7og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331Ab2IDOyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 10:54:36 -0400
In-Reply-To: <504420FD.4030908@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2012 09:16 PM, Ying Xue wrote:
>
>>>
>>> It looks like the case where we come in with "sock->state ==
>>> SS_LISTENING" has changed. Previously we would return -EOPNOTSUPP but
>>> now it'll be -EINVAL. Is that intentional?
>>
>> Just noticed something else.  In the SS_CONNECTING case I don't think 
>> there's any point in setting "res = -EALREADY" since a bit further 
>> down it gets set unconditionally anyway.
>>
> Yes, you are right. Please check v2 version.

Looks good to me.  Still haven't had a chance to actually test it 
though, we're pushing out a release and time is scarce.

Chris
