From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: No Maintainer entry for dl2k driver
Date: Mon, 20 Dec 2004 14:54:50 -0600
Message-ID: <200412201454.50114.jdmason@us.ibm.com>
References: <41C377E9.1040305@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, edward_peng@alphanetworks.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
In-Reply-To: <41C377E9.1040305@wanadoo.es>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thank you for the correction.  However my point remains the same, there is no 
entry in the MAINTAINERS file for the dl2k driver.  So, now it should look 
something like this:

--- MAINTAINERS.orig    2004-12-17 16:01:37.955336376 -0600
+++ MAINTAINERS 2004-12-17 16:07:21.027181528 -0600
@@ -704,6 +704,10 @@ M: mvw@planets.elm.net
 L:     linux-kernel@vger.kernel.org
 S:     Maintained

+DL2K NETWORK DRIVER
+P: Edward Peng
+M: edward_peng@alphanetworks.com
+L:     linux-net@vger.kernel.org
+S:     Maintained
+
 DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
 P:     Tobias Ringstrom
 M:     tori@unhappy.mine.nu



Also, his e-mail address in the dl2k driver needs to be updated, as the one 
currently in the driver (edward_peng@dlink.com.tw) bounces.

Thanks,
Jon

On Friday 17 December 2004 06:20 pm, Xose Vazquez Perez wrote:
> Jon Mason wrote:
> > It has come to my attention that there is no entry in the kernel
> > MAINTAINERS file for the D-Link Gigabit Ethernet Driver (and possibly no
> > maintainer). So, I have created a patch for that file with an entry for
> > the driver status as Orphaned.
>
> Edward Peng <edward_peng@alphanetworks.com> is the current maintainer.
> The 2.4 kernel already has latest release, and 'I think' he is working
> on the 2.6 driver.

-- 
Jon Mason
jdmason@us.ibm.com
