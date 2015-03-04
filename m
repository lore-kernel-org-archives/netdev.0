From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv4 net-next 0/3] Improvements for TCP PMTU
Date: Wed, 04 Mar 2015 10:12:54 +0800
Message-ID: <54F66A26.8080409@gmail.com>
References: <1425374361-21047-1-git-send-email-fan.du@intel.com> <CABrhC0kXWSq3hrfo=dtnmaor0ciDB2wDPaFQ_Vk40sZe4iCfdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38341 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450AbbCDCRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 21:17:52 -0500
Received: by pdbfl12 with SMTP id fl12so22135262pdb.5
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 18:17:52 -0800 (PST)
In-Reply-To: <CABrhC0kXWSq3hrfo=dtnmaor0ciDB2wDPaFQ_Vk40sZe4iCfdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8804=E6=97=A5 00:43, John Heffner =E5=86=
=99=E9=81=93:
> On Tue, Mar 3, 2015 at 4:19 AM, Fan Du<fan.du@intel.com>  wrote:
>> >Fan Du (3):
>> >   ipv4: Raise tcp PMTU probe mss base size
>> >   ipv4: Use binary search to choose tcp PMTU probe_size
>> >   ipv4: Create probe timer for tcp PMTU as per RFC4821
>> >
>> >  include/net/inet_connection_sock.h |    2 +
>> >  include/net/netns/ipv4.h           |    2 +
>> >  include/net/tcp.h                  |    8 +++++-
>> >  net/ipv4/sysctl_net_ipv4.c         |   14 +++++++++++
>> >  net/ipv4/tcp_ipv4.c                |    2 +
>> >  net/ipv4/tcp_output.c              |   46 +++++++++++++++++++++++=
+++++++++---
>> >  net/ipv4/tcp_timer.c               |    1 +
>> >  7 files changed, 70 insertions(+), 5 deletions(-)
>> >
> This changeset adds a couple new sysctls.  They probably deserve
> descriptions in ip-sysctl.txt.

Thanks for the notice, will update ip-sysctl.txt in next version.
