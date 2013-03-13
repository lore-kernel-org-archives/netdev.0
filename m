From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [iproute2] Fix -oneline output when alias present
Date: Wed, 13 Mar 2013 05:20:08 -0700
Message-ID: <51406EF8.5000506@cumulusnetworks.com>
References: <1363125827-14129-1-git-send-email-roopa@cumulusnetworks.com> <20130313094859.GA3097@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext.cumulusnetworks.com ([66.175.223.20]:46561 "EHLO
	ext.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab3CMMUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 08:20:13 -0400
In-Reply-To: <20130313094859.GA3097@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/13 2:48 AM, Andreas Henriksson wrote:
> Hi!
>
> Just wanted to point out some minor style issues with your patch.
> See below...
>
> On Tue, Mar 12, 2013 at 12:03:47PM -0000, roopa@cumulusnetworks.com wrote:
> [...]
>> -	if (do_link&&  tb[IFLA_IFALIAS])
>> -		fprintf(fp,"\n    alias %s",
>> +	if (do_link&&  tb[IFLA_IFALIAS]) {
>> +		fprintf(fp, "%s", _SL_);
>> +		fprintf(fp,"    alias %s",
>
>                            ^^^ missing space here.

Oh, I hadn't noticed that. I did not introduce the style problem there.
I just happened to pick the _SL_line from else where in the code.
Since this patch is in, I will submit a patch to fix the spacing.
>
> Also, why not use a single fprintf?

I was just following convention here. The SL line seems to be on a line 
of its own else where in the code. Which i did think was cleaner.


Thanks.
