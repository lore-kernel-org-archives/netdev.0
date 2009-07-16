From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Bad sky2 interrupt handling?
Date: Thu, 16 Jul 2009 16:25:52 -0700
Message-ID: <20090716162552.7f7b3031@jbarnes-g45>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-148.bluehost.com ([67.222.38.38]:54487 "HELO
	outbound-mail-148.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933574AbZGPXce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 19:32:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was debugging what I thought was a graphics driver problem today (some
page flipping code I'm working on was only flipping at about 10Hz
rather than ~60Hz) but it appears it's actually due to a bad
interaction with the Marvell 88E8036 controller on this machine.

MSI fails on this box (haven't looked too much at why yet), so the i915
driver shares an interrupt with USB, firewire, sdhci and the NIC.

Is sky2 the wrong driver to be using here?  Or is there some way of
reducing its overhead when (presumably) it doesn't have anything to do?

-- 
Jesse Barnes, Intel Open Source Technology Center
