From: Bandan Das <bsd@redhat.com>
Subject: Re: slow networking with VM virtio
Date: Tue, 24 Mar 2015 15:53:40 -0400
Message-ID: <jpgbnjikw8r.fsf@redhat.com>
References: <F1F13E14A610474196571953929C020969A1DD@ex08.net.ucsf.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: "Boylan\, Ross" <Ross.Boylan@ucsf.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754036AbbCXTxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 15:53:42 -0400
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org
In-Reply-To: <F1F13E14A610474196571953929C020969A1DD@ex08.net.ucsf.edu> (Ross
	Boylan's message of "Tue, 24 Mar 2015 19:37:42 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Ccing qemu-devel and kvm]

"Boylan, Ross" <Ross.Boylan@ucsf.edu> writes:

> Running a Windows 7 VM under KVM, with virtio drivers, the networking was so slow as to be non-functional.
> As suggested in comment 11 of  https://bugzilla.redhat.com/show_bug.cgi?id=855640, I did ethtool -K eth1 gro off and speeds got much better, ~150Mb/s, although using speedtest.net it was unable to connect to the server for the upload test.
>
> However, ssh in to the host machine, or to linux VM's running on the same host, became extremely erratic (prone to dropped connections) and slow after making these changes.  I was connected via sshuttle for VPN.
>
> Does anyone have any suggestions?
> I would appreciate a cc.
>
> Thanks.
> Ross Boylan
>
> Details:
> Host is running Debian wheezy on amd64.  Using virt-manager > libvirt > kvm and bridged networking.
> Linux markov00 3.2.0-4-amd64 #1 SMP Debian 3.2.65-1+deb7u2 x86_64 GNU/Linux
> Here's one of the network specifications for libvirt:
>     <interface type='direct'>
>       <mac address='52:54:00:61:xxxx'/>
>       <source dev='eth1' mode='vepa'/>
>       <model type='virtio'/>
>       <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
>    </interface>
>
> The Windows drivers came from http://alt.fedoraproject.org/pub/alt/virtio-win/latest/images/virtio-win-0.1-100.iso in the 32 bit windows 7 directory of the iso (host is 64 bit, as is the emulated machine; Windows 7 is 32 bit). --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
