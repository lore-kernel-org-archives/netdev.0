From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute-3.8 0/6] ip netns bug fixes and enhancements
Date: Thu, 17 Jan 2013 16:44:34 -0800
Message-ID: <87622v5ngt.fsf_-_@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52837 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab3ARAoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 19:44:46 -0500
In-Reply-To: <1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com> (Ben
	Hutchings's message of "Tue, 27 Nov 2012 18:00:39 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a set of patches for iproute2 3.8.  Most of the patches
are just general maintenance and cleanup the final patch adds
some commands to make it possible to find the correlation between
network namespaces and running processes.

The first patch is a significant bug fix for a condition that causes
sysfs to be unmounted on systems that choose to propogate all of the
mounts between their mount namespaces by default.

Eric W. Biederman (6):
      iproute2: Don't propogate mounts out of ip netns exec.
      iproute2: Normalize return codes in "ip netns"
      iproute2: Improve "ip netns add" failure error message
      iproute2: Make "ip netns delete" more likely to succeed
      iproute2: Fill in the ip-netns.8 manpage
      iproute2: Add "ip netns pids" and "ip netns identify"

 ip/ipnetns.c        |  236 ++++++++++++++++++++++++++++++++++++++++++++-------
 man/man8/ip-netns.8 |   64 ++++++++++++++-
 2 files changed, 268 insertions(+), 32 deletions(-)
