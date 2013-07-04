From: poma <pomidorabelisima@gmail.com>
Subject: Re: [libvirt-users] libvirt & virtio_net - host.freeze@reset.domain
Date: Thu, 04 Jul 2013 11:14:52 +0200
Message-ID: <51D53D0C.4050404@gmail.com>
References: <51D2B8A1.9050002@gmail.com> <20130703114327.GW2778@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: libvir-list@redhat.com, netdev@vger.kernel.org,
	libvirt-users@redhat.com,
	"qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>,
	Mateusz Marzantowicz <mmarzantowicz@osdf.com.pl>,
	Virt-tools List <virt-tools-list@redhat.com>
To: "Daniel P. Berrange" <berrange@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:52613 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933532Ab3GDJO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 05:14:56 -0400
In-Reply-To: <20130703114327.GW2778@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.07.2013 13:43, Daniel P. Berrange wrote:
> On Tue, Jul 02, 2013 at 01:25:21PM +0200, poma wrote:
>> Hello people,
>>
>> libvirtd (libvirt) 1.0.5.2
>> virsh 1.0.5.2
>> virt-manager 0.10.0
>>
>> Host:
>> Linux localhost 3.9.8-300.fc19.x86_64 #1 SMP Thu Jun 27 19:24:23 UTC
>> 2013 x86_64 x86_64 x86_64 GNU/Linux
>> Guest1:
>> Linux localhost 3.9.8-300.fc19.i686.PAE #1 SMP Thu Jun 27 19:29:30 UTC
>> 2013 i686 (none)
>> Guest2:
>> Linux localhost 3.9.8-300.fc19.x86_64 #1 SMP Thu Jun 27 19:24:23 UTC
>> 2013 x86_64 x86_64 x86_64 GNU/Linux
>>
>>
>> Virtual NIC - source & model:
>> macvtap/NAT/bridge & virtio(virtio_net)
>>
>> Host freeze at "virsh reset <domain>" or "virt-manager - Force Reset"
>> Need kernel.sysrq or power reset.
> 
> I don't believe this is a libvirt issue - the 'virsh reset' command
> will issue the 'system_reset' QEMU monitor command. This in turn
> does an immediate reset of the guest CPUs/machine.
> 
> Even if QEMU is doing the wrong thing, the kernel should obviously
> never freeze/crash in this way - it should be robust against a
> malicious QEMU process.
> 
> You should probably send this message to the main QEMU and/or KVM
> mailing lists so that it comes to the attention of people who are
> more familiar with QEMU + virtio-net
> 
> 
> Regards,
> Daniel
> 

Thanks for your response.
Mateusz hit the same issue[1] as well.
OK, here we go.


poma


[1] https://lists.fedoraproject.org/pipermail/users/2013-July/436984.html
