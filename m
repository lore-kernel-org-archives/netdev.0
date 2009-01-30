From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Fri, 30 Jan 2009 17:33:24 +1030
Message-ID: <200901301733.25136.rusty@rustcorp.com.au>
References: <OF025C8F2F.2E8FFF17-ON8825754D.0020EE83-8825754D.002299DE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alex Williamson <alex.williamson@hp.com>, kvm@vger.kernel.org,
	markmc@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OF025C8F2F.2E8FFF17-ON8825754D.0020EE83-8825754D.002299DE@us.ibm.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 January 2009 16:47:55 David Stevens wrote:
> Also, if you can't keep all the MAC multicast addresses (ie,
> the limit is memory and not look-up speed), then getting
> out of multicast-promiscuous mode correctly isn't easy
> since you don't know what groups you "forgot". You could
> rebuild from the protocol memberships, if you know when
> you've left enough groups to fit, but otherwise the MAC
> multicast addresses you didn't keep of course won't work if you
> leave multicast-promiscuous mode and the filter doesn't
> have them.

The command is simply "set the filter", not "add" and "delete", so the host doesn't have this problem.

VLAN has more of an issue: that has add and del.  So the host can do a counting hash, or say remember 16 and then a count of overflows, but both will be suboptimal over time.

Cheers,
Rusty.
