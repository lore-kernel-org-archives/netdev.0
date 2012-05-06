From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: ipctl - new tool for efficient read/write of net related sysctl
Date: Sat, 05 May 2012 18:29:28 -0700 (PDT)
Message-ID: <9241f146-d0f7-415b-a652-acd1bf34e95a@tahiti.vyatta.com>
References: <CAHOuc7MQiquWxMZ4YApXXKdsRY_StrTfAK9r_DdkstyYe+kCPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Oskar Berggren <oskar.berggren@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42615 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638Ab2EFB3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2012 21:29:30 -0400
In-Reply-To: <CAHOuc7MQiquWxMZ4YApXXKdsRY_StrTfAK9r_DdkstyYe+kCPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> In a project of mine I need to read (and possibly set) many of the
> properties
> found under /proc/sys/net/ipv4/conf/. This is simple enough, except
> that
> when you have hundreds of interfaces, it is really slow. In my tests
> it takes
> about 4 seconds to read a single variable for 700 interfaces. For a
> while I
> worked around this using the binary sysctl() interface, but this is
> deprecated.
> 

What about exposing these as NETLINK attributes? That would be faster
and you could do bulk updates.
