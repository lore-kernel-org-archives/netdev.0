From: "Jari Takkala" <Jari.Takkala@Q9.com>
Subject: RE: [PATCH 2.6.23.12] net/bonding: option to specify initial bond interface number
Date: Thu, 3 Jan 2008 10:26:12 -0500
Message-ID: <413FEEF1743111439393FB76D0221E4809790A38@leopard.zoo.q9networks.com>
References: <20080102135554.65f86364.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.q9.com ([216.220.35.252]:60649 "EHLO mx3.q9.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755685AbYACP0N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 10:26:13 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080102135554.65f86364.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 02, 2008 16:56, Randy Dunlap wrote:
> You could (should) make <ifnum> be unsigned int and then use
> module_param(ifnum, uint, 0); and then ...
> 
> then this block is mostly useless since ifnum cannot be < 0.
> And how could it ever be > INT_MAX (when ifnum was an int)?
> 
> If <ifnum> is unsigned int but you want to limit it to INT_MAX,
> then half of this if-test would be OK.
> 

Thanks, that makes sense. I simply copied some of the max_bonds code which uses a signed int. I suppose that could be changed as well. I will post back a new patch.

Jari
