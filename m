From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] virtio_net/virtio_ring: fix race in enable_cb
Date: Mon, 17 Mar 2008 13:45:02 +0100
Message-ID: <200803171345.02110.borntraeger@de.ibm.com>
References: <200803141417.05696.borntraeger@de.ibm.com> <200803170730.44218.borntraeger@de.ibm.com> <200803172310.52460.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:5803 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbYCQMpF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 08:45:05 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2HCj4aw185642
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 12:45:04 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HCj3Dv1695878
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 13:45:03 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HCj3Bu015452
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 13:45:03 +0100
In-Reply-To: <200803172310.52460.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 17. M=E4rz 2008 schrieb Rusty Russell:
> > > Are you seeing the "Unlikely: restart svq failed" message in the =
logs?=20
[...]
> Interesting you don't see this.  Or is it just on that load that you =
don't=20
> see it?

Dont know. I have never seen it under my test load.

Christian
