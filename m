From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [evb] RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Mon, 10 Aug 2009 08:20:37 -0700
Message-ID: <20090810082037.17b352c2@nehalam>
References: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com>
	<000001ca17a3$03f841f0$0be8c5d0$@edu>
	<20090807143652.1659ac57@nehalam>
	<4A7EB0AC.2030104@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>, arnd@arndb.de,
	anna.fischer@hp.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	adobriyan@gmail.com, virtualization@lists.linux-foundation.org,
	"evb@yahoogroups.com" <evb@yahoogroups.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39470 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755364AbZHJPVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 11:21:16 -0400
In-Reply-To: <4A7EB0AC.2030104@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 09 Aug 2009 14:19:08 +0300
Or Gerlitz <ogerlitz@voltaire.com> wrote:

> Stephen Hemminger wrote:
> > I have a patch that forwards all multicast packets, and another that does proper forwarding. It should have worked that way in original macvlan, the current behavior is really a bug.
> >   
> Looking in macvlan_set_multicast_list() it acts in a similar manner to
> macvlan_set_mac_address() in the sense that it calls dev_mc_sync(). I
> assume what's left is to add macvlan_hash_xxx multicast logic to
> map/unmap multicast groups to what macvlan devices want to receive them
> and this way the flooding can be removed, correct?

The device can just flood all multicast packets, since the filtering
is done on the receive path anyway.
