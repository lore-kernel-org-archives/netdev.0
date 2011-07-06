From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] AF_PACKET fanout support
Date: Tue, 5 Jul 2011 20:13:27 -0700
Message-ID: <CA+mtBx8www2eNp38EDuagYMQGSYivG7SN4ffozz4QtZPZqubSQ@mail.gmail.com>
References: <20110704.212002.1680758539791986198.davem@davemloft.net>
	<CA+mtBx_MtQGqNT6iungW7eyStpvLEGYsgXQ8=mYq_JR8jw3=DQ@mail.gmail.com>
	<20110705.182041.1392492274453963565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: victor@inliniac.net, netdev@vger.kernel.org, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:41769 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755561Ab1GFDNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 23:13:30 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p663DTsW020475
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 20:13:29 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by hpaq13.eem.corp.google.com with ESMTP id p663CiU9012661
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 20:13:27 -0700
Received: by pvg13 with SMTP id 13so9348240pvg.40
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 20:13:27 -0700 (PDT)
In-Reply-To: <20110705.182041.1392492274453963565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Also, another useful mode of steering would be to steer packets to a
>> socket which was recently processed by a thread running on the same
>> CPU; somewhat analogous to RFS (cc'ed WIllem Bruijn who is already
>> working on this I believe).
>
> This sounds like a good way to overload a local socket and prevent
> pushing the work to lesser used sockets on other cpus.
>
Sure, it you're not using RPS or RSS!  These should already be
distributing the RX work amongst CPUs.
