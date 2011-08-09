From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Tue, 09 Aug 2011 10:53:22 +0200
Message-ID: <4039f2893f574313ee14131c7f9961d3@localhost>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
 <20110801181652.GB2732@nuttenaction>
 <1312223866.2719.3.camel@edumazet-laptop>
 <20110801.175705.2074393848482150971.davem@davemloft.net>
 <1312866027.2531.42.camel@edumazet-laptop>
 <7f02f2970d225cddfad74ee660f39d1d@localhost>
 <1312878988.2371.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <rui314@gmail.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44486 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751097Ab1HIIxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:53:24 -0400
In-Reply-To: <1312878988.2371.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 09 Aug 2011 10:36:28 +0200, Eric Dumazet wrote:



 

> I am speaking of one single conditional branch, the one that is done for

> every BPF instruction done in a filter. It's never taken, so must be

> predicted by the cpu. A perf session could make sure it is  ;)



Ahh, ok - perf is your friend, I know Eric ;-)



>> > +		switch ((enum bpf_inst)fentry->code) {

>> 

>> That should not differ! Eric, sure that this do the trick?

> 

> It is the way to tell gcc to make its optimizations, if they exists on

> enum switch (), as David suggested.



Argl, I see sock_filter.code is declared as __u16 not enum.





Hagen
