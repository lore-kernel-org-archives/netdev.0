From: poma <pomidorabelisima@gmail.com>
Subject: libvirt & virtio_net - host.freeze@reset.domain
Date: Tue, 02 Jul 2013 13:25:21 +0200
Message-ID: <51D2B8A1.9050002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: libvir-list@redhat.com, netdev@vger.kernel.org,
	libvirt-users@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:58991 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab3GBLZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 07:25:25 -0400
Received: by mail-ea0-f174.google.com with SMTP id o10so2640409eaj.19
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 04:25:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello people,

libvirtd (libvirt) 1.0.5.2
virsh 1.0.5.2
virt-manager 0.10.0

Host:
Linux localhost 3.9.8-300.fc19.x86_64 #1 SMP Thu Jun 27 19:24:23 UTC
2013 x86_64 x86_64 x86_64 GNU/Linux
Guest1:
Linux localhost 3.9.8-300.fc19.i686.PAE #1 SMP Thu Jun 27 19:29:30 UTC
2013 i686 (none)
Guest2:
Linux localhost 3.9.8-300.fc19.x86_64 #1 SMP Thu Jun 27 19:24:23 UTC
2013 x86_64 x86_64 x86_64 GNU/Linux


Virtual NIC - source & model:
macvtap/NAT/bridge & virtio(virtio_net)

Host freeze at "virsh reset <domain>" or "virt-manager - Force Reset"
Need kernel.sysrq or power reset.


poma
