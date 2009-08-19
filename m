From: Roland Dreier <rdreier@cisco.com>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Wed, 19 Aug 2009 08:29:10 -0700
Message-ID: <adaeir7256h.fsf@cisco.com>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org>
	<ada7hx22j3g.fsf@cisco.com>
	<alpine.DEB.1.10.0908171814210.15956@gentwo.org>
	<ada3a7p3o6f.fsf@cisco.com> <adaljlg1e0x.fsf@cisco.com>
	<alpine.DEB.1.10.0908190743410.5621@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ams-iport-1.cisco.com ([144.254.224.140]:49036 "EHLO
	ams-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333AbZHSPit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 11:38:49 -0400
In-Reply-To: <alpine.DEB.1.10.0908190743410.5621@gentwo.org> (Christoph
	Lameter's message of "Wed, 19 Aug 2009 07:46:26 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Correct. My Dell R620 may have some weird ACPI info.
 > 
 > SMP: Allowing 32 CPUs, 16 hotplug CPUs
 > 
 > although the box does not have any slots for "hotplugging".

I guess you could try booting with "possible_cpus=16" and see how that
affects things...

 > The patch does not fix the issue so far. We are having various hangs and
 > are trying to figure out what is gong on.

Sounds like the patch lets you get farther?  What kind of hangs do you
get?  Still mlx4-related?

 > We ran an old 2.6.26 debian kernel on this and it worked fine.

The change to mlx4 to use multiple completion interrupts went in around
2.6.29 I think.  So that sort of explains why things would work with 2.6.26.

 - R.
