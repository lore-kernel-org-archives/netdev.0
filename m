From: James M Leddy <james.leddy@redhat.com>
Subject: Re: [PATCH] udp: Add MIB counters for rcvbuferrors
Date: Wed, 25 Jun 2014 17:31:27 -0400
Message-ID: <53AB3FAF.409@redhat.com>
References: <1403035982-6548-1-git-send-email-james.leddy@redhat.com> <20140621.150707.1970046713503112179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754072AbaFYVbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 17:31:32 -0400
In-Reply-To: <20140621.150707.1970046713503112179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2014 06:07 PM, David Miller wrote:
> From: James M Leddy <james.leddy@redhat.com>
> Date: Tue, 17 Jun 2014 16:13:02 -0400
>
>> Add MIB counters for rcvbuferrors in UDP to help diagnose problems.
>>
>> Signed-off-by: James M Leddy <james.leddy@redhat.com>
>
> Please compile test your patches:
>
> net/ipv4/udp.c: In function =A1udp_queue_rcv_skb=A2:
> net/ipv4/udp.c:1538:5: error: label =A1csum_error=A2 used but not def=
ined
> make[1]: *** [net/ipv4/udp.o] Error 1
> make: *** [net/ipv4/udp.o] Error 2
>
> The encapsulation handling above your changes still use that label.
>
> Besides, I see no reason to replace the goto csum_error; with
> doing the counter bump by hand and jumping to "drop".  Especially
> since, as per above, there is another code path which can make
> use of and thus share that csum_error label code.

My bad, resending


--=20
James M Leddy
