From: "John Que" <qwejohn@gmail.com>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Tue, 25 Apr 2006 17:44:37 +0300
Message-ID: <ada605fb0604250744w73c7766as1d3ceb0d62511764@mail.gmail.com>
References: <ada605fb0604250031r2e4a74e7id0b5079fabde9517@mail.gmail.com>
	 <200604250943.49422.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uproxy.gmail.com ([66.249.92.168]:15256 "EHLO uproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932242AbWDYOoj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 10:44:39 -0400
Received: by uproxy.gmail.com with SMTP id c2so1054873ugf
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 07:44:37 -0700 (PDT)
To: "Andi Kleen" <ak@suse.de>
In-Reply-To: <200604250943.49422.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks a lot !

  I had tried the sending RTM_GETROUTE message using a NETLINK_ROUTE
	socket in a User Space program and it went OK.
	
	It gaves correct routing struct which I could parse.
	In fact it gave the rotuing table.
	But in sending that message I did not specify a certain
	dest IP.
	Consider the follwing simple scenario: I have 2 gateways
	(one on eth0,one on eth1), and I am sending
	a packet to some dest IP ; I want to know according to
	that ip on which interface (or gw) it will be out
	
	But where do I specify that certain dest IP ?
Regards,
John
On 4/25/06, Andi Kleen <ak@suse.de> wrote:
> On Tuesday 25 April 2006 09:31, John Que wrote:
> > Hello,
> > What is the right way to determine on which interface card
> > (eth0 or eth1) will a packet be sent (according to the dest IP)?
>
> You can send a rtnetlink RTM_GETROUTE message to ask the kernel.
> Result is the interface index in RTA_OIF, which can be converted
> into a name.
>
> -Andi
>
>
