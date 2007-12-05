From: "Chung-Chi Lo" <linolo@gmail.com>
Subject: [BRIDGE] warning message when add an interface to bridge
Date: Wed, 5 Dec 2007 10:44:17 +0800
Message-ID: <3f696b20712041844h7c049b71reda92edd7b8cb16e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:1753 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbXLECoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 21:44:19 -0500
Received: by wa-out-1112.google.com with SMTP id v27so6701205wah
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 18:44:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My kernel is Linxu 2.6.22.1. SYSFS is off.
When adding an interface to bridge, console will show WARNING message.
If turn SYSFS to on, then the WARNING message is gone.
Any suggestion how to debug this problem? Thanks.

# ifconfig eth0 0.0.0.0
eth0: starting interface.
# brctl addbr br0
# brctl addif br0 eth0
WARNING: at lib/kref.c:33 kref_get()
Call Trace:
[<80027844>] dump_stack+0x8/0x38
[<8011f348>] kref_get+0xdc/0xe4
[<8011ee20>] kobject_get+0x20/0x34
[<8011e910>] kobject_shadow_add+0x5c/0x170
[<8011ea34>] kobject_add+0x10/0x20
[<8020aac0>] br_add_if+0xb4/0x1b4
[<8020b354>] add_del_if+0x5c/0x118
[<8020bcc4>] br_dev_ioctl+0x6c/0x88
[<80182edc>] dev_ifsioc+0x334/0x3c0
[<80183184>] dev_ioctl+0x21c/0x2ec
[<8016f76c>] sock_ioctl+0x130/0x2e4
[<800b3b2c>] do_ioctl+0x6c/0x84
[<800b3d40>] vfs_ioctl+0x80/0x248
[<800b3f58>] sys_ioctl+0x50/0x98
[<8002a8a8>] stack_done+0x20/0x3c
