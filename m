From: jamal <hadi@cyberus.ca>
Subject: [RFC] IP_RECVERRC
Date: Fri, 10 Aug 2007 09:35:12 -0400
Message-ID: <1186752912.5188.12.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:47500 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934295AbXHJNfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 09:35:18 -0400
Received: by wr-out-0506.google.com with SMTP id 36so52218wra
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 06:35:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It seems there are a lot of dumbass apps (latest i have found is iperf
when analyzing batching results) out there whose performance is affected
if they dont set IP_RECVERR. 
If you set that option though you end up getting all these skbs back
to the app which i see as unnecessary work if i am uninterested. I would
like to not do a recvmsg to find out what those messages are - rather
just receiving any errors back.
My proposal is to add another option which is mutually exclusive with
IP_RECVERR that allows for errors only.
Can i get a ye before i implement?

Andi, CCing you because i think you may be the person who added
IP_RECVERR (at least the first time i heard it a few years back was from
you).

cheers,
jamal

