From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: ABORT if receive queue is not empty while closing
 socket
Date: Thu, 30 Jun 2011 12:27:10 -0400
Message-ID: <4E0CA3DE.7010205@hp.com>
References: <20110629135704.GB10085@canuck.infradead.org> <4E0B3491.1060603@hp.com> <20110629143649.GC10085@canuck.infradead.org> <4E0B3DA1.9060200@hp.com> <20110629154814.GD10085@canuck.infradead.org> <4E0B4F71.4020108@hp.com> <20110630133122.GB24074@canuck.infradead.org> <4E0C83FA.2090909@hp.com> <20110630161938.GD24074@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:46443 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab1F3Q1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 12:27:16 -0400
In-Reply-To: <20110630161938.GD24074@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2011 12:19 PM, Thomas Graf wrote:
> On Thu, Jun 30, 2011 at 10:11:06AM -0400, Vladislav Yasevich wrote:
>> On 06/30/2011 09:31 AM, Thomas Graf wrote:
>>> On Wed, Jun 29, 2011 at 12:14:41PM -0400, Vladislav Yasevich wrote:
>>>> Right.  The lack of ABORT from the receive of data is a bug.  I was trying to point out
>>>> that instead of modified the sender of data to send the ABORT, you modify the receiver
>>>> to send the ABORT when it is being closed while having data queued.
>>>
>>> Is this what you had in mind?
>>
>> Almost.  It could really be a simple true/false condition about recvqueue or inqueue
>> being non-empty.  If that's the case, trigger abort.
> 
> What would be the advantage of that?
> 

Wrt to true/false, it's simpler to test for non-empty then it is to go through and count
the data (but I perfectly ok with either way).  WRT to testing the inqueue, as you stated,
not everything may be in receive queue.

-vlad
