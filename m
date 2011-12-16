From: Zang Hongyong <zanghongyong@huawei.com>
Subject: Re: [PATCH 0/2] vhot-net: Use kvm_memslots instead of vhost_memory to
 translate GPA to HVA
Date: Fri, 16 Dec 2011 15:40:01 +0800
Message-ID: <4EEAF5D1.2080805@huawei.com>
References: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
 <1324019151.4496.9.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	xiaowei.yang@huawei.com, hanweidong@huawei.com,
	wusongwei@huawei.com
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1324019151.4496.9.camel@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011/12/16,=E6=98=9F=E6=9C=9F=E4=BA=94 15:05, Sasha Levin =E5=
=86=99=E9=81=93:
> On Fri, 2011-12-16 at 13:32 +0800, zanghongyong@huawei.com wrote:
>> From: Hongyong Zang<zanghongyong@huawei.com>
>>
>> Vhost-net uses its own vhost_memory, which results from user space (=
qemu) info,
>> to translate GPA to HVA. Since kernel's kvm structure already mainta=
ins the
>> address relationship in its member *kvm_memslots*, these patches use=
 kernel's
>> kvm_memslots directly without the need of initialization and mainten=
ance of
>> vhost_memory.
> Conceptually, vhost isn't aware of KVM - it's just a driver which mov=
es
> data from vq to a tap device and back. You can't simply add KVM speci=
fic
> code into vhost.
>
> Whats the performance benefit?
>
But vhost-net is only used in virtualization situation. vhost_memory is=
=20
maintained
by user space qemu.
In this way, the memory relationship can be accquired from kernel=20
without the
need of maintainence of vhost_memory from qemu.
