From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] net: ipv6: inet6_connection_sock.h needs flowi
Date: Mon, 17 Oct 2011 19:59:26 +0300
Message-ID: <4E9C5EEE.6060909@uclouvain.be>
References: <1318671264-19684-1-git-send-email-christoph.paasch@uclouvain.be> <20111015.184126.53610934026688054.davem@davemloft.net> <4E9AA043.1090008@uclouvain.be> <20111016.201310.2196482600418365872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33948 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab1JQQ7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 12:59:32 -0400
In-Reply-To: <20111016.201310.2196482600418365872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2011 03:13 AM, David Miller wrote:
> From: Christoph Paasch<christoph.paasch@uclouvain.be>
> Date: Sun, 16 Oct 2011 12:13:39 +0300
>
>> On 10/16/2011 01:41 AM, David Miller wrote:
>>> From: Christoph Paasch<christoph.paasch@uclouvain.be>
>>> Date: Sat, 15 Oct 2011 12:34:24 +0300
>>>
>>>> Otherwise we have a compiler-warning in c-files not including
>>>> net/flow.h
>>>> before inet6_connection_sock.h .
>>>>
>>>> Signed-off-by: Christoph Paasch<christoph.paasch@uclouvain.be>
>>>
>>> Example?  I've never seen this warning.
>>
>> Currently, all the c-files that include inet6_connection_sock.h
>> indirectly include flow.h before inet6_connection_sock.h. Thus
>> currently there is no compiler-warning.
>
> Then there is no bug you are fixing.

You're right. The patch did not intend to fix a bug (maybe the=20
commit-message should have been more clear about that).
It was intended to make inet6_connection_sock.h not rely on the c-files=
=20
to include flow.h, even if they would not need to. And to do the same=20
for struct flowi as it is done for the other structs in this=20
header-file. Thus it was rather a coding-style patch... :)

But ok, maybe I should not try to change something which is not really=20
broken... ;-)

Christoph


--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=C3=A9 Catholique de Louvain
--=20
