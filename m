From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 1/5] mpls: Use definition for reserved label
 checks
Date: Fri, 20 Mar 2015 14:12:52 +0000
Message-ID: <550C2AE4.6090309@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>	<1426800772-22378-2-git-send-email-rshearma@brocade.com> <87lhisfql4.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:2579 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751190AbbCTONG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 10:13:06 -0400
In-Reply-To: <87lhisfql4.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/03/15 00:41, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
>> index fb6de92..d06dff9 100644
>> --- a/net/mpls/internal.h
>> +++ b/net/mpls/internal.h
>> @@ -9,6 +9,7 @@
>>   #define LABEL_GAL			13 /* RFC5586 */
>>   #define LABEL_OAM_ALERT			14 /* RFC3429 */
>>   #define LABEL_EXTENSION			15 /* RFC7274 */
>> +#define LABEL_FIRST_UNRESERVED		16 /* RFC7274 */
>
> This should reference RFC3032 not RFC7274 as RFC3032 is what defines
> the first 16 labels as reserved.

Thanks - I'll fix that and resend the series.

Rob
