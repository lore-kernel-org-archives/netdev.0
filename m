From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v2 2/2] mpls: fix mpls route deletes to not check
 for route scope
Date: Tue, 02 Jun 2015 08:35:38 -0700
Message-ID: <556DCD4A.6050100@cumulusnetworks.com>
References: <1432751825-40804-3-git-send-email-roopa@cumulusnetworks.com> <20150601.155838.2219594213274495927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com,
	netdev@vger.kernel.org, vivek@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35424 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbbFBPfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 11:35:41 -0400
Received: by igbyr2 with SMTP id yr2so89849369igb.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 08:35:41 -0700 (PDT)
In-Reply-To: <20150601.155838.2219594213274495927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/15, 3:58 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Wed, 27 May 2015 11:37:05 -0700
>
>> -	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
>> -		goto errout;
>> +	if (nlh->nlmsg_type != RTM_DELROUTE &&
>> +		rtm->rtm_scope != RT_SCOPE_UNIVERSE)
>> +			goto errout;
>> +
> This is not indented correctly.
>
> When a conditional spans multiple lines, two things must happen:
>
> 1) Each line must end with an operator rather than begin with one.
>
> 2) Each line starting with the second must start exactly at the
>     first column after the openning parenthesis of the conditional.
>     You must use the appropriate number of TAB then SPACE characters
>     necessary to achieve this.
>
sorry, missed this. I have resubmitted the series. thanks.
