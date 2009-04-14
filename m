From: David Hawkins <dwh@ovro.caltech.edu>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Tue, 14 Apr 2009 15:27:16 -0700
Message-ID: <49E50DC4.3080108@ovro.caltech.edu>
References: <20090224000002.GA578@ovro.caltech.edu> <fa686aa40904141328oa57fb1bsffd0549a52eca90@mail.gmail.com> 	<49E4FED0.1020003@ovro.caltech.edu> <fa686aa40904141445x6a125e12r391e0853d89baf72@mail.gmail.com> 	<49E505B3.5070005@ovro.caltech.edu> <fa686aa40904141516s1ca2965fted07bf2a6f5ce390@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ira Snyder <iws@ovro.caltech.edu>, Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:37289 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbZDNW1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 18:27:15 -0400
In-Reply-To: <fa686aa40904141516s1ca2965fted07bf2a6f5ce390@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

> Hmmm, I hadn't thought about this.  I was intending to use the
> Virtex's memory region for all virtio, but if I can allocate memory
> regions on both sides of the PCI bus, then that may be best.

Sounds like you can experiment and see what works best :)

>> If you use
>> a PCI Target only core, then the MPC5200 DMA controller
>> will have to do all the work, and read transfers might
>> be slightly less efficient.
> 
> I'll definitely intend to enable master mode on the Xilinx PCI controller.

Since you understand the lingo, you clearly understand
there are core differences :)

>> Our target boards (PowerPC) live in compactPCI backplanes
>> and talk to x86 boards that do not have DMA controllers.
>> So the PCI target board DMA controllers are used to
>> transfer data efficiently to the x86 host (writes)
>> and less efficiently from the host to the boards
>> (reads). Our bandwidth requirements are 'to the host',
>> so we can live with the asymmetry in performance.
> 
> Fortunately I don't have very high bandwidth requirements for the
> first spin, so I have some room to experiment.  :-)

Yes, in theory you have enough bandwidth ... then a
few features are added, the PCI core is not quite as
fast as advertised, etc etc :)

Cheers,
Dave
