From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Wed, 12 Sep 2012 17:53:32 +0300
Message-ID: <CAKoUAr=8zZA9EgvJEVrd0a-Uw=zzksHj+5P2Sp3Lb4vXgSJRYA@mail.gmail.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
	<1345724119-32110-2-git-send-email-ogerlitz@mellanox.com>
	<Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>
	<5050668B.1010105@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:46135 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759780Ab2ILOxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 10:53:34 -0400
Received: by lagy9 with SMTP id y9so1167192lag.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 07:53:33 -0700 (PDT)
In-Reply-To: <5050668B.1010105@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>From the dump of CPU #1, it seems indeed not related at all to "modprobe -r".

Could it be that there is some IB stack sysfs write activity?
(regardless of the modprobe -r" you issued) ?  I see some candidates
for it.

delete_child() is a method of the IB stack (ipoib/ipoib_main.c)

Maybe in order to help debug the problem, you might try to add in
delete_child() method, print of the name of the attribute which is
being deleted ?

  (struct device_attribute has a a member "struct attribute attr",
which in turn has  "const char *name").


Regards,
Rami Rosen
