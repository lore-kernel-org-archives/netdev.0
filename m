From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: tunctl issues with FC 12 and 2.6.33-rc5
Date: Fri, 12 Feb 2010 12:32:09 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07559FB80A86@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38495 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446Ab0BLUcJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:32:09 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have built and installed the 2.6.33-rc5 kernel on a machine in which the original distro was Fedora Core 12.  I have a script set up to create a tap device using tunctl but when I boot to the 2.6.33-rc5 kernel I get TUNSETIFF:  Permission Denied.  If I boot to the 2.6.31 based kernel that came with FC 12 the tunctl command works fine and create the tap device.  The problem I need a tap device added to my bridge so I can pass a network interface into one of my KVM virtual machines.

Has anyone seen this problem or might understand why it is occurring?  I checked the netdev archives and found nothing about it there.  Several hours of googling about the internet hasn't provided any insight either.

Thanks,

- Greg Rose
LAD
Intel Corp.
