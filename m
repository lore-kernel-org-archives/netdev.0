From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Sat, 17 Nov 2012 15:37:40 -0800
Message-ID: <87a9ufu7gb.fsf@xmission.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com> <12918.1353190488@obiwan.sandelman.ca>
	<CAD6jFUQguS0oqGuA-HDFV2gd9m_=kZAvKJJq3ymr8zWM2cePXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michael Richardson <mcr@sandelman.ca>,
	tcpdump-workers@lists.tcpdump.org,
	Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33882 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab2KQXhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 18:37:55 -0500
In-Reply-To: <CAD6jFUQguS0oqGuA-HDFV2gd9m_=kZAvKJJq3ymr8zWM2cePXw@mail.gmail.com>
	(Daniel Borkmann's message of "Sun, 18 Nov 2012 00:16:49 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <danborkmann@iogearbox.net> writes:

> Speaking of netsniff-ng where we don't reconstruct VLAN headers, users
> have reported that depending on the NIC/driver resp. ethtool setting,
> they can come in stripped or not (in the pf_packet's rx_ring buffer).
> However, I assume VLAN AUXDATA is always consistent (and so the
> BPF/BPF JIT filtering).

Yes it was a mess before we added software stripping of the vlan headers
a year ago.

Eric
