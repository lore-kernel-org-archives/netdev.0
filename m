From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 0/4] Enable UFO over virtio-net/tap devices
Date: Fri, 05 Jun 2009 17:16:23 -0700
Message-ID: <1244247383.1526.169.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	herbert.xu@redhat.com, rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following set of patches add support for enabling UFO on virtio-net and
tap devices that allows sending/receiving large UDP packets between host and
guest and multiple guests running under KVM.

[PATCH net-next 1/4] IPv6: HW csum support for outgoing large UFO packets
[PATCH net-next 2/4] udp: Handle large UFO packets from untrusted sources
[PATCH net-next 3/4] virtio_net: Allow UFO feature to be set on virtio_net device.
[PATCH net-next 4/4] tun: Allow tap device to send/receive UFO packets.

In order to use this feature, Qemu needs to negotiate and set UFO feature in 
the tap and virtio-net devices. I am also including a patch to qemu-kvm git
that does this.

Thanks
Sridhar


