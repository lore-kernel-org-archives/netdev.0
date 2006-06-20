From: jamal <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Tue, 20 Jun 2006 11:01:37 -0400
Message-ID: <1150815697.5270.86.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <20060620080250.GM1376@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Per Liden <per.liden@ericsson.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Jay Lan <jlan@engr.sgi.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:47535 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751291AbWFTPBj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 11:01:39 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FshjZ-0006Xo-Ma
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 11:01:41 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060620080250.GM1376@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 10:02 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-19 09:41

> One important point about attributes in generic netlink is that
> their scope is per command instead of per family as in netlink.
> It's not forbidden to use the same set of attribute identifiers
> for two separete commands but it should be avoided to have a
> single large list of attributes and have every command pick out
> the attributes it needs.
> 

Thanks - I will add this to the doc. Additionally the commands are 
scoped per registered family (as opposed of needing them to be 
encapsulated in the nlmsg_type).

> 
> > TODO:
> > a) Add a more complete compiling kernel module with events.
> > Have Thomas put his Mashimaro example and point to it.
> 
> I guess we have a legal issue here ;)
> 

change the name ;->

> > b) Describe some details on how user space -> kernel works
> > probably using libnl??
> 
> I'll take care of that.

Whats the plan? To add to this doc or separate doc?

cheers,
jamal

