From: domingo montoya <reach.domingomontoya@gmail.com>
Subject: mlx5 VST and VGT mode at the same time
Date: Thu, 18 Aug 2016 15:11:27 +0530
Message-ID: <CAOYAsNm+t5rWGm+Xe_cq_2=D0H-Ue4uUNzR4LaVJXFueawd4xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37259 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbcHRJlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 05:41:45 -0400
Received: by mail-wm0-f54.google.com with SMTP id i5so23594108wmg.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 02:41:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Is there any way we can support both VST and VGT modes at the same time in mlx5?

For e.g,

If i send untagged packets from the VF, they should be tagged with the
VST vlan and the vlan be stripped for received packets.

If i send tagged packets from the VF, they should be send as it and no
tag inserted for these and also the vlan tag not stripped for received
packets.

Any way we can achieve this?


I understand that in the latest code these features are mutually exclusive.

But if we have a requirement like this, any ideas on how to go about
implementing the same.

Few observations:

After going through the code, I figured out that for VST mode, we run
MODIFY_ESW_VPORT_CONTEXT and as part of this set the flag to strip the
vlan from the received packets. In case of VGT mode, because of this
command, the tags set by the VF driver also get stripped.



Thanks a lot!


Best Regards,
Domingo
