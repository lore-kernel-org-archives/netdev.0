From: "Ian Brown" <ianbrn@gmail.com>
Subject: net 2.6.25 is broken when building with wireless/iwlwifi
Date: Sun, 20 Jan 2008 16:01:15 +0200
Message-ID: <d0383f90801200601y71472ae6ha638c1567d4abde4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:3366 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbYATOBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:01:17 -0500
Received: by py-out-1112.google.com with SMTP id u52so2363342pyb.10
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 06:01:16 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
net 2.6.25 is broken when building with the wireless/iwlwifi
subtree;  we get the following errors (we noticed that iwl_down() and
iwl_resume()
implementation do exist in garzik tree, but there are more differences
so a simple
patch with only adding these two methods might be risky)

...
...

  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC [M]  drivers/net/wireless/iwlwifi/iwl3945-base.o
drivers/net/wireless/iwlwifi/iwl3945-base.c: In function 'iwl3945_pci_remove':
drivers/net/wireless/iwlwifi/iwl3945-base.c:8639: error: implicit
declaration of function 'iwl_down'
drivers/net/wireless/iwlwifi/iwl3945-base.c: In function 'iwl3945_pci_resume':
drivers/net/wireless/iwlwifi/iwl3945-base.c:8779: error: implicit
declaration of function 'iwl_resume'
make[4]: *** [drivers/net/wireless/iwlwifi/iwl3945-base.o] Error 1
make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
make[2]: *** [drivers/net/wireless] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2
...
...
IB
