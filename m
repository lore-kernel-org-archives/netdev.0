From: Dean Nelson <dnelson@redhat.com>
Subject: [net-next-2.6 PATCH 0/9] return PCI_ERS_RESULT_DISCONNECT on permanent failure
Date: Fri, 31 Jul 2009 15:12:55 -0400
Message-ID: <20090731191254.5470.99642.send-patch@aqua>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40797 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508AbZGaTN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2009 15:13:26 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n6VJD2aj030166
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 15:13:13 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n6VJCuVH000497
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 15:13:02 -0400
Received: from [127.0.0.1] (vpn-225-175.phx2.redhat.com [10.3.225.175])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n6VJCtBO023645
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 15:12:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI drivers that implement the struct pci_error_handlers' error_detected
callback should return PCI_ERS_RESULT_DISCONNECT if the state passed in is
pci_channel_io_perm_failure.

There have been a few of this type of net driver that have recently been
modified to address this issue. See the following commits:

http://git.kernel.org/linus/c93b5a76d58656158d195a7df507ebc660010969
http://git.kernel.org/linus/eab633021c26025b34f36f79f0311d3d99f40ceb
http://git.kernel.org/linus/ef681ce1e8b3e63317cd724c200b2fd39286c005
http://git.kernel.org/linus/59ed6eecff4aa00c5c5d18ffd180acac108d596e
http://git.kernel.org/linus/3044b8d1ff8c05237652a692fb572a34e4d70146

This patchset is an attempt to address the remaining net drivers of this type.
None of the patches in this patchset have been tested, since I don't have the
hardware to test any of them. I'm simply making these patches available for
whomever is interested and able to test them, to do so. Perhaps the individual
patches can be committed as they get tested, reviewed and ACK'd.

Apologies in advance if I'm not Cc'ng the correct maintainers of these drivers.

Thanks,
Dean
