From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] net: ptp: oki-semi: fix build dependency
Date: Tue, 01 Apr 2014 16:27:25 +0200
Message-ID: <533ACCCD.8030601@redhat.com>
References: <1396288941-23063-1-git-send-email-ast@plumgrid.com> <20140331185538.GB7729@netboy> <5339EB85.4050308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbaDAO1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 10:27:35 -0400
In-Reply-To: <5339EB85.4050308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2014 12:26 AM, Daniel Borkmann wrote:
> On 03/31/2014 08:55 PM, Richard Cochran wrote:
...
>> We don't really need two copies. As long as you are refactoring this,
>> why not reduce it to just one filter?
>>
>> Something like
>>
>> #if defined(CONFIG_PTP_1588_CLOCK) || defined(CONFIG_NETWORK_PHY_TIMESTAMPING)
>>
>> ... code here ...
>>
>> #endif
>>
>> could go into filter.c or somewhere else in the stack.
>
> I'd move that code into it's own file e.g. ptp_classifier.c and while
> at it also remove PTP_FILTER stuff from the header file entirely and
> hide it all locally in that file. I will cook something tomorrow.

Posted at [1], let me know if that is fine with you, Richard.

Thanks !

   [1] http://patchwork.ozlabs.org/patch/335949/
