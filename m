From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Tue, 06 Jan 2015 21:26:56 +0100
Message-ID: <1420576016.15181.21.camel@redhat.com>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
	 <1420552709.32369.50.camel@stressinduktion.org>
	 <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
	 <1420574353.15181.19.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Ji=C5=99=C3=AD_P=C3=ADrko?= <jiri@resnulli.us>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567AbbAFU1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 15:27:35 -0500
In-Reply-To: <1420574353.15181.19.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-06 at 20:59 +0100, Hannes Frederic Sowa wrote:
> Sorry, I haven't fully understood this. Does rocker first do a L3
> routing table lookup and *after* that does decide which nexthop to chose
> based on preferences in the action-set found at the leaf? My gut tells
> me that we cannot do a semantically equivalent to ip rules then, we
> would have to use ACLs then. Hmm...

Does rocker drop the packet if no match is found or can it pass the
packet onto the slowpath to the kernel?
