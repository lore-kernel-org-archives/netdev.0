From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Wed, 19 Aug 2009 15:58:37 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908191557260.19909@gentwo.org>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org> <ada7hx22j3g.fsf@cisco.com> <alpine.DEB.1.10.0908171814210.15956@gentwo.org> <ada3a7p3o6f.fsf@cisco.com> <adaljlg1e0x.fsf@cisco.com> <alpine.DEB.1.10.0908190743410.5621@gentwo.org> <adaeir7256h.fsf@cisco.com>
 <alpine.DEB.1.10.0908191135110.32015@gentwo.org> <adaab1v1t93.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:58295 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751083AbZHST6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 15:58:53 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 64E1B82C683
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 15:59:11 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id b6fGiTnqSt7A for <netdev@vger.kernel.org>;
	Wed, 19 Aug 2009 15:59:06 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9112B82C73E
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 15:59:02 -0400 (EDT)
In-Reply-To: <adaab1v1t93.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2009, Roland Dreier wrote:

>
>  > System hangs when unloading the mlx4 driver f.e.
>
> I guess that means things work for a while if you get to the point of
> unloading?  Or do you still get an error on load?  Any way to get a
> trace or anything?

It hung on unload. Playing around with BIOS configs now. Seems that C
states were disabled so we also had some ACPI issues.

> BTW, are you using mlx4_en or mlx4_ib?

mlx4_ib.

> I'll try to reproduce here by booting with "possible_cpus=32" and see
> what happens...

Thanks.

