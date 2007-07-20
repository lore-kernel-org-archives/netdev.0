From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] Allow LSM to use IP address/port number.
Date: Fri, 20 Jul 2007 11:28:57 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707201124070.7319@d.namei>
References: <20070709.002629.28788394.davem@davemloft.net>
 <200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp>
 <Line.LNX.4.64.0707091842360.9417@d.namei> <20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net>
 <Line.LNX.4.64.0707091940450.10029@d.namei> <200707210011.HBI60217.FUNOWSFPGEt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:45880 "EHLO
	mail7.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170AbXGTP3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 11:29:06 -0400
In-Reply-To: <200707210011.HBI60217.FUNOWSFPGEt@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 21 Jul 2007, Tetsuo Handa wrote:

> I can't use netfilter infrastructure because
> it is too early to know who the recipant process of the packet is.

I think the way forward on this is to re-visit the idea of providing a 
proper solution for the incoming packet/user match problem.

I posted one possible solution a couple of years ago (skfilter):
http://lwn.net/Articles/157137/

I think there has been some recent discussion by netfilter developers 
about this issue, so perhaps you could talk to them (cd'd Patrick).


- James
-- 
James Morris
<jmorris@namei.org>
