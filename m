From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Wed, 1 Jul 2009 12:42:12 +0300
Message-ID: <200907011242.12812.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907010154.27457.denys@visp.net.lb> <m1iqicyjmr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36653 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbZGAJmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 05:42:21 -0400
In-Reply-To: <m1iqicyjmr.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 July 2009 09:58:36 Eric W. Biederman wrote:
>
> What problem were you originally trying to solve?
>
> Having a proxy arp gateway reply to addresses it routes is proper
> behaviour.
It is not correct behavior to reply to gratuitous ARP, if you dont have this 
IP locally! 

IP conflict detection will fail then completely, if proxy arp machine have 
default route (means answer to ALL ARP requests). 

Sadly RFC 1027 (Proxy ARP) dated in 1987 and not explaining this case well.
I found other source of information, it is not reliable (wikipedia), but it is 
also mentioned in one of HP patents 
(http://www.freepatentsonline.com/y2009/0073990.html). My point of view 
marked as (!!!!!!!).

ARP announcements

An ARP announcement (also known as Gratuitous ARP) is a packet containing 
valid sender hardware and protocol addresses (SHA and SPA) for the host that 
sent it, with identical destination and source addresses (TPA = SPA). Such a 
request (!!!!!!!) is not intended to solicit a reply, but merely updates the 
ARP caches of other hosts that receive the packet. Gratuitous ARP is usually 
an ARP request [3], but it may also be an ARP reply [4].
