From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Intel ASF support
Date: Mon, 9 Jun 2008 03:54:26 +0300
Message-ID: <20080609003521.M40819@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: greg@kroah.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758025AbYFIAyq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If i am writing to wrong maillists and persons, then sorry :-)

Intel have support of ASF in their desktop motherboards, and recently they
moved to AMT platform, which is much more powerful, but also more complicated.
I am already using IPMI, very impressed by IPMI 2.0 and BMC in Sun servers,
and Dell PERC card. But more i am impressed from IPMI support and tools, it is
not great, still there is no kernel drivers for IPMI over SMBus, even there
was unofficial patches before.

But right now i have failures of regular linux kernel on servers made from
simple desktop boards. Additionally i submit bugreport about DP35DP
motherboard, where iTCO_wdt driver not firing watchdog, and it is unresolved
for few month. Maintainer is even not answering now... I seen similar reports
about "35" series of Intel motherboards. Maybe it is just hardware bug of this
series.

So i don't have capability to reboot failed server now, and i was forced to
install power switch on that location (it's hard to reach area, and i cannot
install there full-scale server). So i start reading about ASF and very
interested about RMCP, which is described inside ASF standard. Shortly - it
seems i can reboot and monitor my board remotely!
I think Intel and Linux developers must be interested in this solution, as
soon it let's to manage unreliable software/hardware, people will love such
capability. For me it is VERY important to test unstable features, as soon as
many hardware can be just far away, or even located in dangerous places, where
i need time to get access. 
Also it will bump sales of Intel-based solutions and provide cheaper options,
instead of buying power switches("rebooters").

For example my DP35DP sometimes freezing, and probably it is some bug in
kernel. I want to test also "rc" kernels and provide bug reports before kernel
got released, so i can help a bit for kernel developers, but i cannot take
risk, cause iTCO_wdt not working in this motherboard, software watchdog not
able to reboot PC, and same for nmi_watchdog and hangcheck timer module.

So question is, there is any chance ASF will be supported? At least in some
simple form, just to be able reboot remotely and use ASF watchdog, 
Btw watchdog seems accessed over SMBus, i read it in asfwdg.c, Intel ASF
driver, they made it in 2003, but seems it is abandoned now.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.
