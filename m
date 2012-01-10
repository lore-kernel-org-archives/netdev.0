From: "Naveen B N (nbn)" <nbn@cisco.com>
Subject: RE: [IPsec] CPU usage for IPSec in Linux 2.6.38
Date: Tue, 10 Jan 2012 20:30:08 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA02596D9C@XMB-BGL-416.cisco.com>
References: <B97B134FACB2024DB45F524AB0A7B7F20545EA24@XMB-BGL-419.cisco.com><20203.19901.967544.547378@fireball.kivinen.iki.fi> <B2C779B5E2D74D1792EB988E1B59B42B@trustworks.com> <A2354B6A9F807641B21EEABD666ECEEA02596D7C@XMB-BGL-416.cisco.com> <0769428D-FA00-4928-8E0A-0DEFB214396A@bbn.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "John Lowry" <jlowry@bbn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-2.cisco.com ([72.163.197.26]:2235 "EHLO
	bgl-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245Ab2AJPAL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 10:00:11 -0500
Content-class: urn:content-classes:message
In-Reply-To: <0769428D-FA00-4928-8E0A-0DEFB214396A@bbn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the issue is when adding an entry to SPD 
Database which already contains 4000 entries, because 
The entries have to be checked before adding the 
New entry.

Regards
Naveen  

-----Original Message-----
From: John Lowry [mailto:jlowry@bbn.com] 
Sent: Tuesday, January 10, 2012 8:25 PM
To: Naveen B N (nbn)
Subject: Re: [IPsec] CPU usage for IPSec in Linux 2.6.38

The only time we had troubles like this was with
a Dell 1U that had rotten drivers.  Upgrading to
different kernel and updated drivers fixed the problem.


On Jan 10, 2012, at 8:48 AM, Naveen B N (nbn) wrote:

> Hi All,
> I am using linux 2.6.36 kernel and trying to add 6000 Ikev2/ipsec
> tunnels 
> at 20 Ikev2 messages per second , I am using netlink socket which is
set
> to 
> NON_BLOCKING and i am sending XFRM SPD added for every successful AUTH
> message received.
> 
> But the problem is after the 4000 tunnels are established, CPU usage
> goes 
> to > 90%, which will likely cause dropping of few AUTH response from
> responder.
> 
> NOTE:
> But when I disabled adding SPD messaged via netlink sockets using xfrm
> messages,
> I am able to complete 6000 ikev2 SA negotiation successfully.
> 
> So the problem i am seeing is when sending XFRM netlink message >
4000.
> 
> Any solutions are or analysis different then the above is appreciated.
> 
> 
> Thanks and Regards
> Naveen 
> _______________________________________________
> IPsec mailing list
> IPsec@ietf.org
> https://www.ietf.org/mailman/listinfo/ipsec
