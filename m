From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Fri, 20 Nov 2015 00:02:22 +0100
Message-ID: <1447974142.3068929.444817369.068F6E50@webmail.messagingengine.com>
References: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
 <CALx6S379hXL=QEBF-HmOvPr3K55tS87HV=wKOySro1A0ogmWcQ@mail.gmail.com>
 <20151119.130923.186891318318651425.davem@davemloft.net>
 <1447957669.2293924.444570833.0E151DD6@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, zenczykowski@gmail.com, lorenzo@google.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, dtor@google.com
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39818 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759394AbbKSXCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 18:02:23 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 1E0BE20B36
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 18:02:23 -0500 (EST)
In-Reply-To: <1447957669.2293924.444570833.0E151DD6@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015, at 19:27, Hannes Frederic Sowa wrote:
> I will research the semantics behind tcpdrop:
> <http://www.freebsd.org/cgi/man.cgi?query=tcpdrop&apropos=0&sektion=0&manpath=FreeBSD+10.2-RELEASE&arch=default&format=html>

Fyi, my research shows that it just sends RST and discards complete
socket state.

Bye,
Hannes
