From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 13:07:29 -0700
Message-ID: <20110711130729.607d461e@nehalam.ftrdhcpuser.net>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Greg Scott" <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45684 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346Ab1GKUHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 16:07:30 -0400
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2011 13:25:46 -0500
"Greg Scott" <GregScott@Infrasupport.com> wrote:

> I ran into a strange situation - I am using a firewall set up as a
> bridge.  Physical device eth1 is the private LAN side, eth0 is the
> public Internet side.  I setup bridge br0 to bridge eth0 and eth1
> together.  I need a bridge because this site has a couple of nodes on
> the LAN side that need real public IP Addresses.  
> 
> This site also has a few web and ftp sites.  These are NATed behind the
> firewall, but internal users need to see them the same way as the rest
> of the world.  So I use some iptables SNAT and DNAT rules to make this
> happen.  Device br0 has the relevant public IP Address(es) and then NATs
> to the appropriate private IP Address(es).  The ruleset works and the
> system has been up and running for several years.  
> 
> I recently replaced the old system with a new one running Fedora 14 and
> that's when the weird behavior started.  
> 
> Now, when internal people try to look at those web/ftp sites using the
> public IP Addresses, they get nowhere.  Unless I watch with tcpdump -
> and then while I'm watching , all works as it should.  With some help,
> we figured out the reason it works when watching with tcpdump - because
> tcpdump puts the device being monitored into promiscuous mode.  
> 
> And, sure enough, when I do:
>     ip link set br0 promisc on
> 
> everything works as it should.

Please provide more configuration information like:
  - NIC type
  - iptables and bridge and address configuration

Do you have reverse path filtering enabled/disabled?

