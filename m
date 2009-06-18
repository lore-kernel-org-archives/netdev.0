From: Tilman Schmidt <t.schmidt@phoenixsoftware.de>
Subject: Re: [GIT]: Networking
Date: Fri, 19 Jun 2009 01:18:31 +0200
Message-ID: <4A3ACB47.3050502@phoenixsoftware.de>
References: <20090615.050449.144947903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.phnxsoft.com ([195.227.45.4]:2514 "EHLO
	posthamster.phnxsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbZFRXsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 19:48:16 -0400
In-Reply-To: <20090615.050449.144947903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.06.2009 14:04 schrieb David Miller:
>  Documentation/isdn/00-INDEX                        |   29 +-

It seems something went wrong with the merge. After:

commit aba7453037c3a90714caae77a622dceaf1173786
Merge: a4fe91e 93af7ac
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Apr 29 20:30:35 2009 -0700

    Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
    
    Conflicts:
        Documentation/isdn/00-INDEX
        drivers/net/wireless/iwlwifi/iwl-scan.c
        drivers/net/wireless/rndis_wlan.c
        net/mac80211/main.c

lines 22..28 of Documentation/isdn/00-INDEX now look like this:

       - info on the drivers for Siemens Gigaset ISDN adapters.
README.icn
       - info on the ICN-ISDN-card and its driver.
>>>>>>> 93af7aca44f0e82e67bda10a0fb73d383edcc8bd:Documentation/isdn/00-INDEX
README.HiSax
       - info on the HiSax driver which replaces the old teles.
README.audio

Also, some of the entries, such as README.audio and README.icn, are now duplicated.
Can that be repaired, or would you like me to prepare a patch cleaning it up?

Thanks,
Tilman
