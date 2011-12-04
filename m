From: Alessandro Salvatori <sandr8@gmail.com>
Subject: vmxnet3 driver broken since 3.0?
Date: Sun, 4 Dec 2011 01:15:01 -0800
Message-ID: <CAJeBh4sXMVnZcLcjiMyvpPPoG3708CeaQ3hDj_g2s72Hv09N6g@mail.gmail.com>
Reply-To: sandr8@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:60799 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979Ab1LDJPb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 04:15:31 -0500
Received: by ywa9 with SMTP id 9so3702220ywa.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 01:15:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under both 3.1.3 and 3.0.8, I am seeing the following when I modprobe
vmxnet3 build within the respective kernel tree:

[77314.335684] VMware vmxnet3 virtual NIC driver - version 1.1.18.0-k-N=
API
[77314.335742] alloc_netdev: Unable to allocate device with zero queues=
=2E
[77314.335744] # of Tx queues : 0, # of Rx queues : 0
[77314.335745] Failed to alloc ethernet device for adapter 0000:0b:00.0
[77314.335748] vmxnet3: probe of 0000:0b:00.0 failed with error -12

with 2.6.39.4 the module comes up fine and works fine.

haven't had a chance to try the one from the 3.2 release candidates yet=
=2E

thanks in advance!
-Alessandro-
=A0Here i am, A young man,
=A0A crashing computer program,
=A0Here is a pen, write out my name...

(from: The Servant - Orchestra)
