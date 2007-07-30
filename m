From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support for the bonding driver
Date: Mon, 30 Jul 2007 14:20:22 -0700
Message-ID: <adaejipr3l5.fsf@cisco.com>
References: <46ADDB89.5030601@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:21041 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965212AbXG3VUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 17:20:35 -0400
In-Reply-To: <46ADDB89.5030601@voltaire.com> (Moni Shoua's message of "Mon, 30 Jul 2007 15:37:29 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > 1. When bonding enslaves an IPoIB device the bonding neighbor holds a 
 > reference to a cleanup function in the IPoIB drives. This makes it unsafe to 
 > unload the IPoIB module if there are bonding neighbors in the air. So, to 
 > avoid this race one must unload bonding before unloading IPoIB. 

I think we really want to resolve this somehow.  Getting an oops by
doing "modprobe -r ipoib" isn't that friendly.

Also, what happened to the problem of having an address handle
belonging to the wrong device on bond failover?  Did you figure out a
way to fix that one?

 - R.
