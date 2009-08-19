From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Wed, 19 Aug 2009 11:47:36 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908191135110.32015@gentwo.org>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org> <ada7hx22j3g.fsf@cisco.com> <alpine.DEB.1.10.0908171814210.15956@gentwo.org> <ada3a7p3o6f.fsf@cisco.com> <adaljlg1e0x.fsf@cisco.com> <alpine.DEB.1.10.0908190743410.5621@gentwo.org>
 <adaeir7256h.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:53899 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752123AbZHSPrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 11:47:41 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9E56C82C6B3
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 11:47:58 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4c3SjmsGyoKc for <netdev@vger.kernel.org>;
	Wed, 19 Aug 2009 11:47:54 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 011B282C60D
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 11:47:53 -0400 (EDT)
In-Reply-To: <adaeir7256h.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2009, Roland Dreier wrote:

>  > although the box does not have any slots for "hotplugging".
>
> I guess you could try booting with "possible_cpus=16" and see how that
> affects things...

I configured the kernel with a maximum of 16 cpus and things are fine.

> Sounds like the patch lets you get farther?  What kind of hangs do you
> get?  Still mlx4-related?

System hangs when unloading the mlx4 driver f.e.
