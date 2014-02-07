From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Cascading Bond devices
Date: Fri, 7 Feb 2014 08:41:49 +0100
Message-ID: <20140207074149.GA17815@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([88.198.249.254]:59085 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbaBGHlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 02:41:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I wonder if it is possible to cascade bond devices. I have currently a
box with four network cards. Two are going to switch a and two are going
to switchb. And what I would like to do is the following:

switch-01 port 1 - eth0 \
switch-01 port 2 - eth1 - bond0 (802.3ad Layer 2 hash) \
switch-02 port 1 - eth2 - bond1 (802.3ad Layer 2 hash) - bond2 (active-passive)
switch-02 port 2 - eth3 /

If it is possible, how would I configure such a scenario? bond0 and
bond1 is easy and in fact I already have them. But I don't get howto to
use adifferent hashing algorithm for bond2.

I also wanted to use tlb/alb in the past but experienced broadcast
storms when using IPv6 on such devices. Also I was not able to set an
IPv6 address because of duplicated address detection told me that it was
already online on the subnet which it was not. This was with kernel 3.12
and 3.13.

Cheers,
        Thomas
