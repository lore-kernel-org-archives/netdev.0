From: Shailabh Nagar <nagar@watson.ibm.com>
Subject: Re: [DOC]: generic netlink
Date: Mon, 19 Jun 2006 18:37:55 -0400
Message-ID: <44972743.3040904@watson.ibm.com>
References: <1150724482.5815.48.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>,
	Per Liden <per.liden@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:3563 "EHLO
	mtagate6.uk.ibm.com") by vger.kernel.org with ESMTP id S964958AbWFSWia
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 18:38:30 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k5JMcTIx121522
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 22:38:29 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5JMdlEQ114142
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 23:39:47 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5JMcSpd022360
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 23:38:29 +0100
To: hadi@cyberus.ca
In-Reply-To: <1150724482.5815.48.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Folks,
> 
> Attached is a document that should help people wishing to use generic
> netlink interface. It is a WIP so a lot more to go if i see interest.
> The doc has been around for a while, i spent part of yesterday and this
> morning cleaning it up. If you have sent me comments before, please
> forgive me for having misplaced them - just send again. 

Jamal,

Completing the documentation on generic netlink usage will definitely be
useful. I'd be happy to help out with this since I've recently gone through
trying to understand and use genetlink for the taskstats interface. Hopefully
this will help other users like me who aren't netlink experts to begin with !

I've sent you a patch to the document that attempts to cover the following
TODOS (didn't see any point sending it to the whole list since its harder to
read patches to documentation). Pls use as you see fit.

> TODO:
> a) Add a more complete compiling kernel module with events.
> Have Thomas put his Mashimaro example and point to it.
(not the Mashimaro example, nor a completly compiled module but snippets
of pseudo code taken from the user space program used in taskstats development,
modified to the foobar example you've used)
> b) Describe some details on how user space -> kernel works
> probably using libnl??
> c) Describe discovery using the controller..

I'll provide another patch that will cover d) and e) in the set below, again
in the context of the foobar example, which might need to be modified a bit.

> d) talk about policies etc
> e) talk about how something coming from user space eventually
> gets to you.
> f) Talk about the TLV manipulation stuff from Thomas.
> g) submit controller patch to iproute2

One point...does d), f) etc. belong in a separate doc describing usage
of netlink attributes ? Its useful here too but not directly related to
genetlink perhaps.

> PS:- I dont have a good place to put this doc and point to, hence the
> 17K attachment
>

http://www.kernel.org/pub/linux/kernel/people/hadi/ ?

(unless your permissions have been revoked for lack of use ! :-)

Having the current document will be useful to see what edits have been accepted
and work on that instead of the original.

--Shailabh
