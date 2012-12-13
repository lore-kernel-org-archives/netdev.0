From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 13 Dec 2012 14:07:45 -0800
Message-ID: <CAOxq_8NTCV_ORimfet5FO0tH=9HQUy9Gy=ZeV9sFoWDAP8XagA@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<21992.1351723328@obiwan.sandelman.ca>
	<alpine.OSX.2.00.1212121205040.78903@animac.local>
	<50C9936B.2000201@redhat.com>
	<CAOxq_8PuMF2n80g30aXbPFQyo6UfsypZOHREjB36dnnp87nv=A@mail.gmail.com>
	<CAD6jFUTht82HOjGjDU7hFCEWyE3TOx_W4_j=SZK-DrcGfrio-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:35796 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756058Ab2LMWHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 17:07:46 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so2486407iay.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 14:07:46 -0800 (PST)
In-Reply-To: <CAD6jFUTht82HOjGjDU7hFCEWyE3TOx_W4_j=SZK-DrcGfrio-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 1:49 PM, Daniel Borkmann
<danborkmann@iogearbox.net> wrote:

> Well, not everyone on netdev might be following this thread (resp.
> following fully). The best way to get responses for a patch is to go
> through the normal patch submission process on netdev, and if you like
> to request for comments, then mark it as RFC in the subject. This way,
> people will know and likely comment on it if it makes sense or not.

OK good to know.

> As Eric mentioned earlier, for now there seems not to be a reliable
> way to get to know which ops are present and which not. It's not
> really nice, but if you want to make use of those new (ANC*) features,
> probably checking kernel version might be the only way if I'm not
> missing something. Now net-next is closed, but if it reopens, I'll
> submit a version 2 of my patch where you've been CC'd to. If it gets
> in, then at least it's for sure that since kernel <xyz> this kind of
> feature test is present.

thanks, yes, I believe we do need some sort of validation on the
ancilliary features.
