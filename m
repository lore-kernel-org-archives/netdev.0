From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Thu, 9 Jul 2015 19:28:58 +0200
Message-ID: <CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>
	<559EAD2A.2090002@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35755 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbbGIR27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 13:28:59 -0400
Received: by wiga1 with SMTP id a1so319066060wig.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 10:28:58 -0700 (PDT)
In-Reply-To: <559EAD2A.2090002@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 9, 2015 at 7:19 PM, David Ahern <dsa@cumulusnetworks.com> wrote:

> On the to-do list to use cmsg to specify a VRF for outbound packets using
> non-connected sockets. I do not believe it is going to work, but need to
> look into it.
>
>> What about setting ipsec policy for interfaces in the vrf?

>From a purely parochial standpoint, how would rds sockets work in this model?
Would the tcp encaps happen before or after the the vrf "driver" output?
Same problem for NFS.

>From a non-parochial standpoint. There are a *lot* of routing apps that actually
need more visibility into many details about the "slave" interface: e.g., OSPF,
ARP snoop, IPSLA.. the list is pretty long.

I think it's a bad idea to use a "driver" to represent a table lookup. Too many
hacks will become necessary.

--Sowmini
