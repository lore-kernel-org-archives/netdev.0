From: Jeff Garzik <jeff@garzik.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Mon, 06 Apr 2009 14:49:48 -0400
Message-ID: <49DA4ECC.9050204@garzik.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>	<49DA4C85.5090806@garzik.org> <20090406114432.3a554eba@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robin Getz <rgetz@blackfin.uclinux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>,
	Matt Mackall <mpm@selenic.com>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45733 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708AbZDFSty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 14:49:54 -0400
In-Reply-To: <20090406114432.3a554eba@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The real problem one is xen-netfront. Because 1) it is least random,
> the attacker might be another VM 2) the VM is most in need of random
> samples because it doesn't have real hardware.

Agreed.

I'm surprised Xen doesn't use virtio-rng.  I guess it needs a special 
Xen paravirt driver for randomness.

	Jeff


