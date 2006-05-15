From: "Mark Wallis" <mwallis@serialmonkey.com>
Subject: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 22:57:12 +1000
Message-ID: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from qvfw1.qvalent.com ([202.7.65.65]:35265 "EHLO mail.qvalent.com")
	by vger.kernel.org with ESMTP id S932114AbWEOM5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 08:57:33 -0400
Received: from qvts2 (unknown [192.168.40.87])
	by mail.qvalent.com (Postfix) with ESMTP id 7582F2D
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 22:44:23 +1000 (EST)
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone,

During our development of the rt2x00 wireless driver we have come across an
interesting issue that we want to get comment on from the netdev-community.

Some laptops with our Ralink cards build-in also include a hardware button
that is meant to enable/disable the wireless card. We are wondering how we
should handle this.

Currently, in our rt2x00 (using the devicescape stack) we are firing off an
ACPI event so that the hardware button can be handled in userspace. This
allows the user to basically do whatever they want when this button is
pressed - including bringing down the wireless interface. The problem here
is no distro's currently contain scripts to run from this event so for many
users it just "doesn't work" without them manually having to write scripts
to handle the ACPI even themselves.

Some people are saying that instead of throwing and ACPI event we should be
either use hotplug or internally just disable the radio and somehow inform
the dscape stack that the radio has been disabled.

What are peoples thoughts here, should we 

A. be handling this within our drivers and doing "what the user expects" and
disabling the hardware radio, or 

B. should we be firing an ACPI event and getting the distro's to add scripts
so when this event is fired they bring down all the wireless interfaces.

Regards,
Mark Wallis
Project Admin
http://rt2x00.serialmonkey.com
mwallis@serialmonkey.com

