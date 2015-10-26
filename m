From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 12:16:49 -0700
Message-ID: <9831.1445887009@famine>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org> <562E4C26.3030501@gmail.com> <1445877236.175039.420582401.131556D5@webmail.messagingengine.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48712 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbbJZTQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 15:16:53 -0400
In-reply-to: <1445877236.175039.420582401.131556D5@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

>Hello Alex,
>
>On Mon, Oct 26, 2015, at 16:52, Alexander Duyck wrote:
>> Seems like this code isn't quite correct.  You are calling ipv6_add_dev 
>> for slave devices, and if I understand things correctly I don't believe 
>> that was happening before and may be an unintended side effect.
>
>Ah, btw., autoconf and ipv6 operation on IFF_SLAVE devices is actually
>desired nowadays and don't think we can change this. See also:
><https://patchwork.ozlabs.org/patch/531196/>

	IPv6 addrconf on IFF_SLAVE devices was disabled for bonding
slaves in commit c2edacf80e15 because it caused issues with snooping
switches.

	This is also referenced in

https://bugzilla.redhat.com/show_bug.cgi?id=236750

	Won't re-enabling autoconf on IFF_SLAVE devices cause that issue
to return?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
