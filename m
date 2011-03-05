From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 0/8] mostly bonding rx path changes
Date: Sat, 5 Mar 2011 10:35:00 +0100
Message-ID: <20110305093459.GH5071@psychotron.redhat.com>
References: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
 <1299316329.2758.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab1CEJfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 04:35:41 -0500
Content-Disposition: inline
In-Reply-To: <1299316329.2758.75.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 05, 2011 at 10:12:09AM CET, eric.dumazet@gmail.com wrote:
>Le samedi 05 mars 2011 =E0 09:29 +0100, Jiri Pirko a =E9crit :
>> This patchset focuses mainly bonding rx path changes.
>>=20
>> Depends on "fcoe: correct checking for bonding"
>>=20
>> Jiri Pirko (8):
>>   af_packet: use skb->skb_iif instead of orig_dev->ifindex
>>   bonding: register slave pointer for rx_handler
>>   net: get rid of multiple bond-related netdevice->priv_flags
>>   bonding: wrap slave state work
>>   bonding: get rid of IFF_SLAVE_INACTIVE netdev->priv_flag
>>   bonding: move processing of recv handlers into handle_frame()
>>   net: introduce rx_handler results and logic around that
>>   net: get rid of orig_dev parameter of packet handlers
>>=20
>
>Jiri, I do believe your changelogs are not very helpful ...
>
>Oh wait, maybe you forgot to _include_ them ?

Well, I tried to explain that in subject. I think that most of patches
are very local so additional description would be redundant. Truth is
that I could comment "net: introduce rx_handler results and logic aroun=
d
that" or perhaps "bonding: move processing of recv handlers into
handle_frame()" more.

/me thinks that he needs to learn how to write novels...

Anyway. I can repost with some more text if you like.

>
>;)
>
>
