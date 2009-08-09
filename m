From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: [evb] RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Sun, 09 Aug 2009 14:19:08 +0300
Message-ID: <4A7EB0AC.2030104@Voltaire.com>
References: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com>	<000001ca17a3$03f841f0$0be8c5d0$@edu> <20090807143652.1659ac57@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>, arnd@arndb.de,
	anna.fischer@hp.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	adobriyan@gmail.com, virtualization@lists.linux-foundation.org,
	"evb@yahoogroups.com" <evb@yahoogroups.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:19975 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751674AbZHILTV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 07:19:21 -0400
In-Reply-To: <20090807143652.1659ac57@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> I have a patch that forwards all multicast packets, and another that does proper forwarding. It should have worked that way in original macvlan, the current behavior is really a bug.
>   
Looking in macvlan_set_multicast_list() it acts in a similar manner to
macvlan_set_mac_address() in the sense that it calls dev_mc_sync(). I
assume what's left is to add macvlan_hash_xxx multicast logic to
map/unmap multicast groups to what macvlan devices want to receive them
and this way the flooding can be removed, correct?


Or.


