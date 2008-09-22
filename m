From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Mon, 22 Sep 2008 17:00:57 +0400
Message-ID: <48D79709.80400@bigtelecom.ru>
References: <48D4F85C.8090709@bigtelecom.ru> <200809202111.01256.denys@visp.net.lb> <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local> <48D76813.9000603@bigtelecom.ru> <20080922112452.GB5314@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:47429 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbYIVNBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 09:01:06 -0400
In-Reply-To: <20080922112452.GB5314@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> BTW: could you try to trigger this bug with one network card off?
>   


Shire! I stop eth1 and do "/etc/init.d/bgpd stop" (this pc not get route
traffic anymore)....

run "emerge portage" 2 times and get:

[25492.187405] CPU 3: Machine Check Exception: 0000000000000005
[25492.187405] MCE: The hardware reports a non fatal, correctable
incident occurred on CPU 1.
[25492.187405] Bank 0: b200004000000800
[25492.187405] MCE: The hardware reports a non fatal, correctable
incident occurred on CPU 1.
[25492.187405] Bank 5: b200120014040400
[25497.124884] CPU 1: Machine Check Exception: 0000000000000004
[25497.124884] Kernel panic - not syncing: Unable to continue
[25497.124884] Rebooting in 3 seconds..

bugtracker updated.... i can get (reproduce) error on all 10 servers at
2.6.26.5... I use TC and not wont test 2.6.27-rc because its have (if i
understand) multiqueue feature that not tested...

Thanks!
