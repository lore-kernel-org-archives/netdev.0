From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10 00/12] Add driver bpf hook for early packet drop
 and forwarding
Date: Wed, 20 Jul 2016 12:14:16 -0700 (PDT)
Message-ID: <20160720.121416.1466060476760134617.davem@davemloft.net>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
	<20160719.220959.1735534229001351021.davem@davemloft.net>
	<6a09ce5d-f902-a576-e44e-8e1e111ae26b@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: ttoukan.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcGTTOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 15:14:18 -0400
In-Reply-To: <6a09ce5d-f902-a576-e44e-8e1e111ae26b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <ttoukan.linux@gmail.com>
Date: Wed, 20 Jul 2016 12:18:49 +0300

> 
> On 20/07/2016 8:09 AM, David Miller wrote:
>> From: Brenden Blanco <bblanco@plumgrid.com>
>> Date: Tue, 19 Jul 2016 12:16:45 -0700
>>
>>> This patch set introduces new infrastructure for programmatically
>>> processing packets in the earliest stages of rx, as part of an effort
>>> others are calling eXpress Data Path (XDP) [1]. Start this effort by
>>> introducing a new bpf program type for early packet filtering, before
>>> even an skb has been allocated.
>>>
>>> Extend on this with the ability to modify packet data and send back
>>> out
>>> on the same port.
>> Series applied, thanks.
> 
> Hi Dave,
> 
> The series causes compilation errors in our driver (and warnings).
> Please revert it.

Asking for a revert in such a knee-jerk reaction like this is not
appropriate.

Never ask me to do this.

Why don't you try to figure out what the simple fix is instead?

Meanwhile I've already pushed out the appropriate fix.
