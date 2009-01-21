From: kristrev@simula.no
Subject: Re: RFC: Latency reducing TCP modifications for thin-stream      
     interactive applications
Date: Wed, 21 Jan 2009 14:50:15 +0100 (CET)
Message-ID: <92d5db086b180f1241f7258fabae8f1b.squirrel@webmail.uio.no>
References: <496B59B7.3010302@simula.no>
    <Pine.LNX.4.64.0901121705010.1889@wrl-59.cs.helsinki.fi>
    <e5152d316be79cafaf55fcf7bff64d46.squirrel@webmail.uio.no>
    <Pine.LNX.4.64.0901201736370.1889@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: kristrev@simula.no, "Andreas Petlund" <apetlund@simula.no>,
	"Netdev" <netdev@vger.kernel.org>, griff@simula.no,
	paalh@ifi.uio.no
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33143 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbZAUNuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 08:50:17 -0500
In-Reply-To: <Pine.LNX.4.64.0901201736370.1889@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

> Trimmed all but netdev (and .no addresses) from cc list.

Thank you.

>> If I have understood the code correctly, what will then be the
>> difference
>> between our current solution and the one you suggest (except we can
>> remove
>> one of the bundling methods and when a packet is retransmitted)? If I
>> have
>> not understood the code correctly, feel free to yell :) (if it is a
>> misunderstanding, it also explains all the checks for skb->cloned).
>
> It didn't mean clone an skb but copy the relevant data into new skb which
> is then not put into write queue at all but given to lower layers only.

Thank you, now I understand what you meant and I agree that it is a better
solution. However, when I think of it, copying might be too resource
intensive and thus remove all gains from RDB. We have seen streams with 
small packets and very low interarrival times, which would lead to a large
number of copy-operations every second. I will implement it and compare
performance.

-Kristian

