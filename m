From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC 0/0] Introducing a generic socket offload framework
Date: Sat, 20 Aug 2011 10:32:35 -0400
Message-ID: <1313850755.1734.724.camel@mojatatu>
References: <20110818220756.5C93E5C80B@san.sea.corp.google.com>
	 <1313758185.16299.43.camel@mojatatu>
	 <CAPi7mHp==JPA-0vNZ+xWRzOuJYUxsUL3UY=o=VtMUsB-YcFHwQ@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	digitaleric@google.com, mikew@google.com, miche@google.com,
	maccarro@google.com
To: San Mehat <san@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:64660 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083Ab1HTOck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 10:32:40 -0400
In-Reply-To: <CAPi7mHp==JPA-0vNZ+xWRzOuJYUxsUL3UY=o=VtMUsB-YcFHwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-19 at 07:58 -0700, San Mehat wrote:

> Can you explain a good use-case for SOCK_RAW in this type of
> environment? We were noodling it around locally and couldn't come up
> with one that we needed to support.

One that comes to mind is the case of Samir's app: youd need to handle
some of the apps that ride on top of IP typically using SOCK_RAW
eg ping, OSPF essentially anything on IP that doesnt have transport
built into kernel etc; 

> > Q: If you want this to be transparent to the apps, who/what is doing
> > the tagging of SOCK_HWASSIST? clearly not the app if you dont want to
> > change it.
> 
> The decision of whether to tag a socket or not is made by the 'hardware'

As in some config interface? 

cheers,
jamal

