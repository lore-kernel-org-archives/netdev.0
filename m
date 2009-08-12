From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: AlacrityVM numbers updated for 31-rc4
Date: Wed, 12 Aug 2009 18:05:31 -0500
Message-ID: <4A834ABB.4010801@codemonkey.ws>
References: <4A83296B.3080606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	alacrityvm-users@lists.sourceforge.net,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:45049 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbZHLXFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 19:05:34 -0400
In-Reply-To: <4A83296B.3080606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
> I re-ran the numbers on 10GE against the actual alacrityvm v0.1 release
> available in git on kernel.org.
>
> I tried to include the newly announced "vhost" driver (Michael Tsirkin)
> for virtio acceleration, but ran into issues getting the patches to apply.
>
> For now, this includes native, virtio-u (virtio-userspace), and venet
> all running on 31-rc4.  If I can resolve the issue with Michaels
> patches, I will add "virtio-k" (virtio-kernel) to the mix as well.  For
> now, here are the results for 1500mtu:
>
> native:   7388Mb/s,   29.8us rtt (33505 tps udp-rr)
> venet:    3654Mb/s,   56.8us rtt (17600 tps udp-rr)
> virtio-u: 1955Mb/s, 4016.0us rtt (  249 tps udp-rr)
>   

Just FYI, the numbers quoted are wrong for virtio-u.  Greg's machine 
didn't have high res timers enabled in the kernel.  He'll post newer 
numbers later but they're much better than these (venet is still ahead 
though).

Regards,

Anthony Liguori
