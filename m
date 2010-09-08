From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 16:12:41 +0200
Message-ID: <201009081612.41976.arnd@arndb.de>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <4C875735.9050808@redhat.com> <OFAA7EBCA4.A8F764FD-ON65257798.0035E8C2-65257798.00385450@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, anthony@codemonkey.ws,
	davem@davemloft.net, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OFAA7EBCA4.A8F764FD-ON65257798.0035E8C2-65257798.00385450@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 September 2010, Krishna Kumar2 wrote:
> > The new guest and qemu code work with old vhost-net, just with reduced
> > performance, yes?
> 
> Yes, I have tested new guest/qemu with old vhost but using
> #numtxqs=1 (or not passing any arguments at all to qemu to
> enable MQ). Giving numtxqs > 1 fails with ENOBUFS in vhost,
> since vhost_net_set_backend in the unmodified vhost checks
> for boundary overflow.
> 
> I have also tested running an unmodified guest with new
> vhost/qemu, but qemu should not specify numtxqs>1.

Can you live migrate a new guest from new-qemu/new-kernel
to old-qemu/old-kernel, new-qemu/old-kernel and old-qemu/new-kernel?
If not, do we need to support all those cases?

	Arnd
