From: Brad House <brad@mcve.com>
Subject: Re: forcedeth: version 0.17 available
Date: Mon, 17 Nov 2003 23:38:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB9A261.7080500@mcve.com>
References: <3FB807A3.8010207@gmx.net> <3FB98C18.8090305@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Brad House <brad_mssw@gentoo.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
In-Reply-To: <3FB98C18.8090305@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Well, the problem I saw was with the 2.6 patch.

These lines:

+++ build-2.6/drivers/net/forcedeth.c	2003-11-15 23:00:30.000000000 +0100
@@ -0,0 +1,1416 @@

Should be

+++ build-2.6/drivers/net/forcedeth.c	2003-11-15 23:00:30.000000000 +0100
@@ -0,0 +1,1418 @@


Otherwise, the last 2 lines:
+module_init(init_nic);
+module_exit(exit_nic);

Get cut off.

-Brad


Carl-Daniel Hailfinger wrote:
> Carl-Daniel Hailfinger wrote:
> 
>>version 0.17 of forcedeth for Linux 2.4 and 2.6 is available at
>>http://www.hailfinger.org/carldani/linux/patches/forcedeth/
> 
> 
> The patches for Linux 2.4 were malformed. Corrected versions have been
> uploaded a few hours ago.
> Thanks to Brad House for spotting this.
> 
> 
> Regards,
> Carl-Daniel
> 
> 
