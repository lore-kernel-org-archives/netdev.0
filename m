From: ebiederm@xmission.com (Eric W. Biederman)
Subject: REGRESSION: On 2.6.32-rc5 the firmware hangs, and the nic is unusable.
Date: Tue, 03 Nov 2009 23:40:50 -0800
Message-ID: <m1tyxaagal.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38908 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbZKDHkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 02:40:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2.6.31.5 I get:
ethtool -i eth0
driver: netxen_nic
version: 4.0.30
firmware-version: 4.0.305
bus-info: 0000:06:00.0

And everything works except bonding.

On 2.6.32-rc5 I dhcp I get an IP
there is a sanity test ping.

Then the driver reports a firmware hang and
the interface goes down and I am dead in the water.

I'm a bit frustrated with this as it seems with each kernel release
the driver gets a little bit less usable.

Have I given you enough information to track this down?

Eric
