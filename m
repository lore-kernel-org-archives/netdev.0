From: Rick Jones <rick.jones2@hp.com>
Subject: Re: getaddrinfo - should accept IPPROTO_SCTP no?
Date: Fri, 13 Oct 2006 16:48:26 -0700
Message-ID: <453025CA.70506@hp.com>
References: <45300564.2050504@hp.com> <5640c7e00610131559n4a3ad8c5x66cf4b72deb57868@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	DCCP Mailing List <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:20382 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1752002AbWJMXsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 19:48:30 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
In-Reply-To: <5640c7e00610131559n4a3ad8c5x66cf4b72deb57868@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In all the DCCP code which has similar issues I just do the protocol
> selection on the socket call e.g.
>         case TCP:
>             new_sock = socket(AF_INET,SOCK_STREAM,0);
>             break;
>         case DCCP:
>             new_sock = socket(AF_INET,SOCK_DCCP,IPPROTO_DCCP);
>             break;
>         case UDP:
>             new_sock = socket(AF_INET,SOCK_DGRAM,0);
>             break;
> 
> I'm sure you know all this anyway so apologies in advance for telling
> you something you probably already know!

No worries.

David mentioned that I need to talk to the glibc folks.  I'm still trying to web 
search my way to finding them.  Meanwhile I may do in netperf for this what I do 
for Solaris' arbitrary clearing of the ai_protocol field - kludge around it and 
have netperf emit a warning.

rick jones
