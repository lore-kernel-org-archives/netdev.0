From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: sctp: minor: make jsctp_sf_eat_sack
 static
Date: Wed, 13 Feb 2013 20:14:05 +0100
Message-ID: <511BE5FD.9050307@redhat.com>
References: <cover.1360752304.git.dborkman@redhat.com> <7eef4b701794c1bb78819bc6e6c45bf99b49801d.1360752304.git.dborkman@redhat.com> <20130213.140436.521031425285650154.davem@davemloft.net> <20130213.140607.144614341798606281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44431 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759057Ab3BMTOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 14:14:09 -0500
In-Reply-To: <20130213.140607.144614341798606281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2013 08:06 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 13 Feb 2013 14:04:36 -0500 (EST)
>
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Wed, 13 Feb 2013 12:03:49 +0100
>>
>>> The function jsctp_sf_eat_sack can be made static, no need to extend
>>> its visibility.
>>>
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>
>> It's exported for the jprobe lookup by ->symbol_name
>>
>> Did you test this?
>
> Never mind, I mis-read this, the symbol name is for the routine being
> shadowed by the jprobe, which is exported.
>
> These two patches look fine and I'll apply them, thanks Daniel.

Thanks Dave, yes, I did a test doing cat on /proc/net/sctpprobe
while running a simple SCTP client / server.
