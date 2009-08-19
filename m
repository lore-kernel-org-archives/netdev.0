From: Roland Dreier <rdreier@cisco.com>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Wed, 19 Aug 2009 12:46:48 -0700
Message-ID: <adaab1v1t93.fsf@cisco.com>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org>
	<ada7hx22j3g.fsf@cisco.com>
	<alpine.DEB.1.10.0908171814210.15956@gentwo.org>
	<ada3a7p3o6f.fsf@cisco.com> <adaljlg1e0x.fsf@cisco.com>
	<alpine.DEB.1.10.0908190743410.5621@gentwo.org>
	<adaeir7256h.fsf@cisco.com>
	<alpine.DEB.1.10.0908191135110.32015@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:6372 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbZHSTqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 15:46:47 -0400
In-Reply-To: <alpine.DEB.1.10.0908191135110.32015@gentwo.org> (Christoph
	Lameter's message of "Wed, 19 Aug 2009 11:47:36 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > System hangs when unloading the mlx4 driver f.e.

I guess that means things work for a while if you get to the point of
unloading?  Or do you still get an error on load?  Any way to get a
trace or anything?

BTW, are you using mlx4_en or mlx4_ib?

I'll try to reproduce here by booting with "possible_cpus=32" and see
what happens...

 - R.
