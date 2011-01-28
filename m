From: Joe Perches <joe@perches.com>
Subject: fwd: .35 vs .37 suspend/resume corrected defect
Date: Fri, 28 Jan 2011 10:44:29 -0800
Message-ID: <1296240269.2448.238.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: "Leonardo L. P. da Mata" <barroca@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3472 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754039Ab1A1Sob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 13:44:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Leonardo.

This is very much more appropriate for the mailing lists.
I'm forwarding your mail on to those lists.

-------- Forwarded Message --------
From: Leonardo  L. P. da Mata <barroca@gmail.com>
[]
I have a 2.6.35 kernel that is showing some errors like this
(sorry, i don't have the exactly call trace, but is very similar to
this one):
[   93.344045] Call Trace:
[   93.344051]  [<ffffffff8103aabb>] ? warn_slowpath_common+0x7b/0xc0
[   93.344054]  [<ffffffff8103abb5>] ? warn_slowpath_fmt+0x45/0x50
[   93.344057]  [<ffffffff813af93f>] ? ieee80211_work_work+0x2ef/0x13b0
[   93.344061]  [<ffffffff811d362c>] ? string+0x4c/0xe0
[   93.344064]  [<ffffffff81036c60>] ? default_wake_function+0x0/0x20
[   93.344067]  [<ffffffff813b0a74>] ? ieee80211_work_purge+0x74/0xd0
[   93.344070]  [<ffffffff813b1857>] ? ieee80211_stop+0x57/0x4e0
[   93.344073]  [<ffffffff8133c44a>] ? dev_deactivate+0x1aa/0x1d0
[   93.344077]  [<ffffffff81328551>] ? __dev_close+0x41/0x70
[   93.344079]  [<ffffffff81328592>] ? dev_close+0x12/0x40
[   93.344082]  [<ffffffff81328615>] ? rollback_registered_many+0x55/0x2c0
[   93.344085]  [<ffffffff8132888e>] ? unregister_netdevice_many+0xe/0x70
[   93.344088]  [<ffffffff813b0da4>] ? ieee80211_remove_interfaces+0xa4/0xe0
[   93.344092]  [<ffffffff813a2536>] ? ieee80211_unregister_hw+0x46/0x100
[   93.344097]  [<ffffffffa00dea29>] ? rt2x00lib_remove_dev+0xc9/0xd0 [rt2x00lib]
[   93.344101]  [<ffffffffa0054136>] ? rt2x00usb_disconnect+0x36/0x80 [rt2x00usb]
[   93.344111]  [<ffffffffa00a6254>] ? usb_unbind_interface+0xc4/0x120 [usbcore]
[   93.344115]  [<ffffffff81282090>] ? __device_release_driver+0x60/0xd0
[   93.344118]  [<ffffffff812821d5>] ? device_release_driver+0x25/0x40
[   93.344126]  [<ffffffffa00a64dc>] ? usb_rebind_intf+0x1c/0x60 [usbcore]
[   93.344133]  [<ffffffffa00a65bd>] ? do_unbind_rebind+0x7d/0xb0 [usbcore]
[   93.344141]  [<ffffffffa00a66ce>] ? usb_resume+0xde/0x180 [usbcore]
[   93.344144]  [<ffffffff81286ac2>] ? pm_op+0x1a2/0x1c0
[   93.344147]  [<ffffffff81286cc8>] ? device_resume+0x88/0x130
[   93.344151]  [<ffffffff81059740>] ? async_thread+0x0/0x260
[   93.344153]  [<ffffffff81286d84>] ? async_resume+0x14/0x40
[   93.344156]  [<ffffffff81059845>] ? async_thread+0x105/0x260
[   93.344159]  [<ffffffff81036c60>] ? default_wake_function+0x0/0x20
[   93.344162]  [<ffffffff81059740>] ? async_thread+0x0/0x260
[   93.344165]  [<ffffffff81052afe>] ? kthread+0x8e/0xa0
[   93.344168]  [<ffffffff81003b94>] ? kernel_thread_helper+0x4/0x10
[   93.344171]  [<ffffffff81052a70>] ? kthread+0x0/0xa0
[   93.344178]  [<ffffffff81003b90>] ? kernel_thread_helper+0x0/0x10
[   93.344179] ---[ end trace 8223f2954477be04 ]---


I have to ask you if your patches are the responsible for solving this
bug on the kernel 2.6.37, because on the 37 the problem doesn't exist.
BTW this is a problem related with suspend and resuming. One thing
that i notice is that disabling the network and wifi modules, that
problem does not work.

Please, let me know if you think that this message is more useful on
the mailing list.

-- 
Leonardo Luiz Padovani da Mata
barroca@gmail.com

"May the force be with you, always"
"Nerd Pride... eu tenho. Voce tem?"


