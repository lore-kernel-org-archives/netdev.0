From: James Ketrenos <jketreno@linux.intel.com>
Subject: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Fri, 24 Feb 2006 16:29:58 -0600
Message-ID: <43FF88E6.6020603@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932616AbWBXW3h@vger.kernel.org>
To: NetDev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Intel is pleased to announce the launch of an open source project to
support the Intel PRO/Wireless 3945ABG Network Connection mini-PCI
express adapter (IPW3945).

The project is hosted at http://ipw3945.sourceforge.net.  A development
mailing list is available (linked from the top of the IPW3945 project
page.)  You can find the current development release for the adapter by
following the links on the project home page.

A stable [end user targetted] version is not yet available. Those
interested in using the development version should review
the notice linked to from the project page.  A stable version should
be available in the next few weeks.

Aside from a form factor change (our prior wireless cards were mini PCI
while this one is mini PCI express), this project has also changed the
division of work between what occurs on the adapter and what the host is
responsible for performing.  The microcode and hardware provide lower
level MAC services (timings, backoffs, transmit queue management, etc.)
The host is responsible for middle and upper layer MAC services.

As a result of this change, some of the capabilities currently required
to be provided on the host include enforcement of regulatory limits for
the radio transmitter (radio calibration, transmit power, valid
channels, 802.11h, etc.)  In order to meet the requirements of all
geographies into which our adapters ship (over 100 countries) we have
placed the regulatory enforcement logic into a user space daemon that
we provide as a binary under the same license agreement as the
microcode.  We provide that binary pre-compiled as both a 32-bit and
64-bit application.  The daemon utilizes a sysfs interface exposed by
the driver in order to communicate with the hardware and configure the
required regulatory parameters.

Those familiar with our prior projects may be pleased with the changes
we have made with the license agreement for binary portions of this new
project.  We were able to provide a more easily understood agreement
for the binary components required for the adapter to function.  While
this new license still restricts against reverse engineering and
modification, it has been changed to allow easier redistribution.  You
can find the terms of the agreement accessible from the microcode
and daemon download page linked to from the project site.

The current development snapshot contains backward compatibility code
to allow the driver to work in older kernels.  We will be removing 
that code prior to submitting the driver for inclusion in the kernel.

Thanks,
James
