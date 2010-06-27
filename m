From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: Reviewing batman-adv for net/
Date: Mon, 28 Jun 2010 01:15:23 +0200
Message-ID: <201006280115.25518.lindner_marek@yahoo.de>
References: <201006260214.06662.sven.eckelmann@gmx.de>
	<20100627222706.GC8285@nuttenaction>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20100627222706.GC8285@nuttenaction>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Hagen,

> o Where are the advantages of BATMAN compared to OLSR? OLSR is standardized
>   by the IETF which is a great advantage compared to BATMAN. 20 byte IPv4
> 	header respective 60 byte IPv6 header savings? Network protocol
> neutrality? Where are the differences between BATMAN and 802.11s? Where
> are the similarities? See commit 37c5798968d0ce4 of 802.11s

the OLSR as standardized by the IETF is known to be flawed when used outside of 
a simulator (even the IETF Manet people know this - I spoke with one of them). 
We have assembled a few documents explaining some of its weaknesses on our 
website (www.open-mesh.org) but I suggest you get in touch with the folks of 
www.olsr.org. They can go into the details of why they don't follow the RFC.

The B.A.T.M.A.N. kernel module implementation operates on layer 2.5 and as 
such, is not limited to wifi networks (opposed to 802.11s) but can run on any 
interface supporting ethernet frames. The project has its roots in the free 
wireless network scene (specially Freifunk) and is used by many communities 
and companies around the globe.


> o Are there any publications which describe the protocol behavior in
> detail? I assume it is a pro-active protocol - similar to standard BATMAN
> - but what about neighbor discovery, TC, HNA and the like? What about
> multicast transport? It is difficult to rate the patchset if no one knowns
> what the intended behavior is.

Yes, it is a pro-active protocol and we have a set of documentation about it. 
Please check our website and feel free to ask if you have more questions.

Regards,
Marek
