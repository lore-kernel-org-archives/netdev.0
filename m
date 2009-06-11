From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Thu, 11 Jun 2009 14:45:28 +0300
Message-ID: <15ddcffd0906110445x25e2b2c5qa8445e0e1b344ef4@mail.gmail.com>
References: <adaski83ciy.fsf@cisco.com>
	 <20090609.221209.07018418.davem@davemloft.net>
	 <15ddcffd0906100318u2a61b7d8g991fe52439e07928@mail.gmail.com>
	 <20090610.050122.261415364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdreier@cisco.com, cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@voltaire.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:57021 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbZFKLp3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 07:45:29 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1472002fga.17
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 04:45:29 -0700 (PDT)
In-Reply-To: <20090610.050122.261415364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 3:01 PM, David Miller<davem@davemloft.net> wrot=
e:
> From: Or Gerlitz <or.gerlitz@gmail.com>

>> for --unicast-- the same problem [...] will come into play under bot=
h Ethernet and IB,
>> so the user is limited by the socket buffer len and the neigh unres_=
qlen systcl.

> But this generally does not cause problems via ARP, why might that be=
?
> Because resolution is 1) rare 2) quick. =A0Both of which do not apply=
 to this IPoIB case.

To be precise, I don't see why ARP resolution is more rare then
joining to a multicast
group on behalf of a sender in IPoIB, they both happen on the first
and if/when the kernel
deletes the neighbour.

> Sure, but that's just pushing the problem around instead of solving i=
t.

Let me think about it more.

Or.
