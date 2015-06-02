From: Shradha Shah <sshah@solarflare.com>
Subject: Re: [PATCH net-next v2 01/14] sfc: Add code to export port_num in
 netdev->dev_port
Date: Tue, 2 Jun 2015 10:14:51 +0100
Message-ID: <556D740B.8000701@solarflare.com>
References: <556C5704.4060901@solarflare.com>	<556C575C.2040403@solarflare.com> <20150601.120100.1499695282057656297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:42665 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932207AbbFBJPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 05:15:08 -0400
In-Reply-To: <20150601.120100.1499695282057656297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/06/15 20:01, David Miller wrote:
> From: Shradha Shah <sshah@solarflare.com>
> Date: Mon, 1 Jun 2015 14:00:12 +0100
> 
>> In the case where we have multiple functions (PFs and VFs), this
>> sysfs entry is useful to identify the physical port corresponding
>> to the function we are interested in.
>>
>> Signed-off-by: Shradha Shah <sshah@solarflare.com>
> 
> This is a low effort change.
> 
> You retained all of the error handling changes that were only necessary when
> you added the new sysfs file, but are completely unnecessary if you're
> just reporting it via netdev->dev_port.

With the addition of the sysfs change in my previous version, the error handling
code required the addition of a fail4 tag to deal with the sysfs file on the
error path.

Without the sysfs file in my current version v2, there is no extra fail4 tag, I
have reverted back to using fail3.

The changes that are seen in the patch are stylistic changes following the rule
that every branch of an if statement should have parenthesis if one of the
branch uses parenthesis.

The previous version of the patch touched this bit of code so the style change
was relevant.

I think my mistake here is that I left it in v2 as a style change, but I can
assure you that I looked at the error path before submitting the patch and
also that this patch does not affect the error path.

Maybe I should have separated the style change to go as a different patch.

I will do so now and submit a v3.

Thanks.

> 
> This is extremely disappointing, because you expect me to put a good effort
> into reviewing your changes yet you aren't putting that level of effort into
> the submission itself.
> 

-- 
Many Thanks,
Regards,
Shradha Shah
