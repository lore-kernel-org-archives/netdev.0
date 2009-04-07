From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 07 Apr 2009 01:27:41 -0700
Message-ID: <49DB0E7D.2070300@goop.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>	<49DA4C85.5090806@garzik.org> <20090406114432.3a554eba@nehalam> <49DA4ECC.9050204@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>,
	Matt Mackall <mpm@selenic.com>,
	David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:57627 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223AbZDGI1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 04:27:45 -0400
In-Reply-To: <49DA4ECC.9050204@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Stephen Hemminger wrote:
>> The real problem one is xen-netfront. Because 1) it is least random,
>> the attacker might be another VM 2) the VM is most in need of random
>> samples because it doesn't have real hardware.
>
> Agreed.
>
> I'm surprised Xen doesn't use virtio-rng.  I guess it needs a special 
> Xen paravirt driver for randomness. 

Yes, sampling randomness in a PV driver is pretty pointless.  We could 
do the guest end of an entropy sink entirely in usermode, but at present 
there's no dom0 support for an entropy source.

    J
