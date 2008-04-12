From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.25? 1/3] forcedeth: mac address fix
Date: Sat, 12 Apr 2008 04:42:32 -0400
Message-ID: <480075F8.4050801@garzik.org>
References: <200804110430.m3B4UZ5C000433@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com, yhlu.kernel@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41688 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755655AbYDLImg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 04:42:36 -0400
In-Reply-To: <200804110430.m3B4UZ5C000433@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> This critical patch fixes a mac address issue recently introduced.  If the
> device's mac address was in correct order and the flag
> NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the flag would get
> cleared.  During next load, the mac address would get reversed because the
> flag is missing.
> 
> As it has been indicated previously, the flag is cleared across a low power
> transition.  Therefore, the driver should set the mac address back into the
> reversed order when clearing the flag.
> 
> Also, the driver should set back the flag after a low power transition to
> protect against kexec command calling nv_probe a second time.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: "Yinghai Lu" <yhlu.kernel@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |   26 ++++++++++++++++++++++++--
>  1 file changed, 24 insertions(+), 2 deletions(-)

applied


