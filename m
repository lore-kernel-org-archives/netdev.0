From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: Bug#644281: linux-image-3.0.0-1-amd64: problem after changing mtu size on jme kernel module
Date: Fri, 7 Oct 2011 14:24:26 +0800
Message-ID: <20111007062340.M45708@cooldavid.org>
References: <20111004181353.3212.57206.reportbug@ASUS> <1317961087.4024.28.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: 644281@bugs.debian.org, kantacki <kantacki@o2.pl>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:52534 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293Ab1JGGbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 02:31:35 -0400
In-Reply-To: <1317961087.4024.28.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Oct 2011 05:17:52 +0100, Ben Hutchings wrote
> On Tue, 2011-10-04 at 20:13 +0200, kantacki wrote:
> > Package: linux-2.6
> > Version: 3.0.0-3
> > Severity: important
> > Tags: upstream
> > 
> > Hello,
> > 
> > When I try to execute:
> > ifconfig eth0 mtu 4000 up
> > or
> > ifconfig eth0 mtu 7198 up
> > my nic stops working and changing back to mtu 1500 does not help.
> > To use my nic again I have to execute:
> > rmmod jme
> > modprome jme
> > and the the command ifconfig eth0 mtu 1500 $IP up works and enables the network
> > 
> > My network card is Jmicron
> [...]
> 
> Can you look into this, please?
> 
> It appears that jme_change_mtu() doesn't stop the RX path and doesn't
> immediately reallocate RX buffers, and I think it should.  Maybe that's
> not the problem though.
> 
> Ben.
> 
> -- 
> Ben Hutchings
> For every action, there is an equal and opposite criticism. - Harrison

I'll find some time to look into it this weekend.
Thanks for the report. :)

Guo-Fu Tseng
