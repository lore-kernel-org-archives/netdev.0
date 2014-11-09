From: devzero@web.de
Subject: BUG ? - natsemi: Allow users to disable workaround for DspCfg reset
Date: Sun, 9 Nov 2014 20:44:48 +0100
Message-ID: <trinity-83a3e1d0-0840-4d1e-98c1-e9e968c4af05-1415562288729@3capp-webde-bs47>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"Mark Brown" <broonie@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:52257 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbaKITov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Nov 2014 14:44:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

i wanted to get rid of some heavy natsemi driver dmesg spamming like

Apr  1 11:50:06 debian7 kernel: [ 4400.311000] eth0: possible phy reset: re-initializing
Apr  1 11:50:06 debian7 kernel: [ 4400.311319] eth0: DSPCFG accepted after 0 usec.
Apr  1 11:50:06 debian7 kernel: [ 4400.311433] eth0: Wake-up event 0x80000b
Apr  1 11:50:06 debian7 kernel: [ 4400.311537] eth0: Setting full-duplex based on negotiated link capability.

and was happy to find a module param - but i`m confused about dspcfg_workaround parameter usage. 

i can indeed disable the spamming by setting natsemi.dspcfg_workaround=0 at boot.

but should`t /sys/devices/pci0000:00/0000:00:0f.0/dspcfg_workaround  reflect the current state then and shouldn`t i be able to set this also via echo 0|1 or off|on >..... at runtime ? that does not seem to work. it always shows "off" and i cannot change the behaviour via this file.

regards
roland

references:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=1a14780960888c97371a9918f42c4dbe6957efb4

ps:
jeff/mark - pardon, i sent the mail a second time because of mistyping mailinglist-adress due to marc.info list naming... 
