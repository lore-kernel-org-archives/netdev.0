From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC net-next] bonding: notify when bonding device address
 changes
Date: Sat, 16 Apr 2011 09:18:04 -0700
Message-ID: <20110416091804.5e6b0b9f@nehalam>
References: <20110415184407.550abd88@pomiocik.lan>
	<4DA89114.9040900@gmail.com>
	<10227.1302893590@death>
	<20110415121054.73717900@nehalam>
	<11728.1302895704@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas de =?UTF-8?B?UGVzbG/DvGFu?= <nicolas.2p.debian@gmail.com>,
	=?UTF-8?B?TWljaGHFgiBHw7Nybnk=?= <mgorny@gentoo.org>,
	netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52640 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877Ab1DPQSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 12:18:06 -0400
In-Reply-To: <11728.1302895704@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2011 12:28:24 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> >When a device changes its hardware address, it needs to call the network
> >device notifiers to inform protocols.
> >
> >Compile tested only.

I did not audit that all the call sites have the proper locking.
When calling notifier, no bridge locks should be held and RTNL mutex
should be held.
