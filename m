From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'libertas-fixes' branch of wireless-2.6
Date: Mon, 02 Jul 2007 08:14:47 -0400
Message-ID: <4688EC37.3080305@garzik.org>
References: <20070627205539.GB13617@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	dcbw@redhat.com
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50743 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758886AbXGBMOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:14:53 -0400
In-Reply-To: <20070627205539.GB13617@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 189548642c5962e60c3667bdb3a703fe0bed12a6:
>   Linus Torvalds (1):
>         Linus 2.6.22-rc6
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git libertas-fixes
> 
> Dan Williams (4):
>       libertas: style fixes
>       libertas: kill wlan_scan_process_results
>       libertas: fix WPA associations by handling ENABLE_RSN correctly
>       libertas: remove private ioctls
> 
>  drivers/net/wireless/libertas/Makefile  |    2 +-
>  drivers/net/wireless/libertas/README    |  275 --------
>  drivers/net/wireless/libertas/assoc.c   |   28 +-
>  drivers/net/wireless/libertas/cmd.c     |   12 +-
>  drivers/net/wireless/libertas/cmdresp.c |   21 +
>  drivers/net/wireless/libertas/hostcmd.h |    2 +-
>  drivers/net/wireless/libertas/ioctl.c   | 1081 -------------------------------
>  drivers/net/wireless/libertas/main.c    |    8 +-
>  drivers/net/wireless/libertas/scan.c    |   51 +--
>  drivers/net/wireless/libertas/wext.c    |  152 -----
>  drivers/net/wireless/libertas/wext.h    |   45 +--
>  11 files changed, 79 insertions(+), 1598 deletions(-)
>  delete mode 100644 drivers/net/wireless/libertas/ioctl.c

pulled


