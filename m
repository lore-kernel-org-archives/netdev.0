From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: =?UTF-8?B?SXMgZmFsbGJhY2sgdmhvc3RfbmV0IHRvIHFlbXUgZm9yIGxpdmUgbWk=?=
 =?UTF-8?B?Z3JhdGUgYXZhaWxhYmxl77yf?=
Date: Tue, 27 Aug 2013 11:32:31 +0800
Message-ID: <521C1DCF.5090202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<qianhuibin@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5841 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047Ab3H0Ddt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 23:33:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

I am participating in a project which try to port vhost_net on Xen=E3=80=
=82

By change the memory copy and notify mechanism =EF=BC=8Ccurrently virti=
o-net=20
with vhost_net could run on Xen with good performance=E3=80=82TCP recei=
ve=20
throughput of single vnic from 2.77Gbps up to 6Gps=E3=80=82In VM receiv=
e=20
side=EF=BC=8CI instead grant_copy with grant_map + memcopy=EF=BC=8Cit e=
fficiently=20
reduce the cost of grant_table spin_lock of dom0=EF=BC=8CSo the hole se=
rver TCP=20
performance from 5.33Gps up to 9.5Gps=E3=80=82

Now I am consider the live migrate of vhost_net on Xen=EF=BC=8Cvhost_ne=
t use=20
vhost_log for live migrate on Kvm=EF=BC=8Cbut qemu on Xen havn't manage=
 the=20
hole memory of VM=EF=BC=8CSo I am trying to fallback datapath from vhos=
t_net to=20
qemu when doing live migrate =EF=BC=8Cand fallback datapath from qemu t=
o
vhost_net again after vm migrate to new server=E3=80=82

My question is=EF=BC=9A
	why didn't vhost_net do the same fallback operation for live migrate o=
n=20
KVM=EF=BC=8Cbut use vhost_log to mark the dirty page=EF=BC=9F
	Is there any mechanism fault for the idea of fallback datapath from=20
vhost_net to qemu for live migrate=EF=BC=9F

any question about the detail of vhost_net on Xen is welcome=E3=80=82

Thanks
