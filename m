From: Josh Hunt <johunt@akamai.com>
Subject: Re: panic on boot with latest net-next
Date: Fri, 06 Feb 2015 17:42:05 -0600
Message-ID: <54D5514D.4010204@akamai.com>
References: <54D52BD6.2080109@akamai.com> <20150206221028.GA13706@casper.infradead.org> <54D53C11.1000208@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:46230 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566AbbBFXmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 18:42:06 -0500
In-Reply-To: <54D53C11.1000208@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2015 04:11 PM, Josh Hunt wrote:
> On 02/06/2015 04:10 PM, Thomas Graf wrote:
>> On 02/06/15 at 03:02pm, Josh Hunt wrote:
>>> I'm hitting the following crash on boot with the latest net-next
>>> (2ca292d968ef20cb04f31192d1f626bd8d782960):
>>
>> Thanks for the report.
>>
>> This should be fixed by the patches posted in the thread:
>> [PATCH 0/6 v2 net-next] rhashtable fixes
>
> Thanks. I will apply those and see if it resolves my issue.

Applying those fixed my problem. I also just pulled the latest net-next 
with this series applied and that works as well.

Thanks
Josh
