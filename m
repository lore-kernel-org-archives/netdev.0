From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCHES] TX batching
Date: Mon, 24 Sep 2007 20:15:55 -0400
Message-ID: <46F8533B.9010405@garzik.org>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>	 <20070916.161748.48388692.davem@davemloft.net>	 <1189988958.4230.55.camel@localhost> <1190569987.4256.52.camel@localhost>	 <46F6AE18.7080708@garzik.org> <1190574713.5030.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: hadi@cyberus.ca, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35535 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546AbXIYAQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 20:16:36 -0400
In-Reply-To: <1190574713.5030.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> If the intel folks will accept the patch i'd really like to kill 
> the e1000 LLTX interface.


If I understood DaveM correctly, it is sounding like we want to 
deprecate all of use LLTX on "real" hardware?  If so, several such 
projects might be considered, as well as possibly simplifying TX 
batching work perhaps.

Also, WRT e1000 specifically, I was hoping to minimize changes, and 
focus people on e1000e.

e1000e replaces (deprecates) large portions of e1000, namely the support 
for the PCI Express modern chips.  When e1000e has proven itself in the 
field, we can potentially look at several e1000 simplifications, during 
the large scale code removal that becomes possible.

	Jeff


