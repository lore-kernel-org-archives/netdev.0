From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 01 Dec 2015 22:54:54 +0100
Message-ID: <1449006894.3839234.455160217.6BE59AFD@webmail.messagingengine.com>
References: <20151201080652.5cba6f8b@xeon-e3>
 <20151201.142847.1980856920707150414.davem@davemloft.net>
 <20151201122038.795305df@xeon-e3>
 <20151201.155725.733555238839381632.davem@davemloft.net>
 <1449004499.3829359.455124521.608D0A9E@webmail.messagingengine.com>
 <20151201134407.3018adcc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, max@rfc2324.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:58398 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756103AbbLAVyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 16:54:55 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A0A8D20BC9
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 16:54:54 -0500 (EST)
In-Reply-To: <20151201134407.3018adcc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, Dec 1, 2015, at 22:44, Stephen Hemminger wrote:
> On Tue, 01 Dec 2015 22:14:59 +0100
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > I had several snmp installations with net-snmp and munin, cacti and so
> > on and all had the interface name in ifDescription already some years
> > back.
> 
> In net-snmp 5.7 or later ifDescr is set to result of pci_lookup_name
> (by default).

Seems the data should simply be in ifName nowadays (unconfirmed):
<http://www.net-snmp.org/docs/mibs/ifMIBObjects.html>

Bye,
Hannes
