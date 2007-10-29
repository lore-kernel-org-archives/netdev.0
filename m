From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Mon, 29 Oct 2007 05:48:14 -0400
Message-ID: <4725AC5E.3080006@garzik.org>
References: <20071026030826.GB14080@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43884 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629AbXJ2JsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 05:48:18 -0400
In-Reply-To: <20071026030826.GB14080@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Jeff,
> 
> A few fixes for 2.6.24...
> 
> Thanks,
> 
> John
> 
> ---
> 
> Individual patches available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik
> 
> ---
> 
> The following changes since commit c9927c2bf4f45bb85e8b502ab3fb79ad6483c244:
>   Linus Torvalds (1):
>         Linux 2.6.24-rc1
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik
> 
> Anton Blanchard (3):
>       ipw2100/ipw2200: jiffies_round -> jiffies_round_relative
>       rt2x00: jiffies_round -> jiffies_round_relative
>       b43/b43legacy: jiffies_round -> jiffies_round_relative
> 
> Michael Wu (1):
>       rtl8187: Allow multicast frames
> 
> Mohamed Abbas (3):
>       iwl4965: fix scan problem
>       iwl3945: cancel scan on rxon command
>       iwl3945: fix direct scan problem
> 
> Tomas Winkler (1):
>       iwlwifi: fix sending probe request in iwl 4965
> 
> mabbas (1):
>       iwl4965: fix driver hang related to hardware scan
> 
>  drivers/net/wireless/b43/main.c             |    2 +-
>  drivers/net/wireless/b43legacy/main.c       |    2 +-
>  drivers/net/wireless/ipw2100.c              |   11 +++--
>  drivers/net/wireless/ipw2200.c              |    6 +-
>  drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +--
>  drivers/net/wireless/iwlwifi/iwl3945-base.c |   56 +++++++++++++++++++++++----
>  drivers/net/wireless/iwlwifi/iwl4965-base.c |   56 +++++++++++++++++++++++----
>  drivers/net/wireless/rt2x00/rt2x00lib.h     |    2 +-
>  drivers/net/wireless/rtl8187_dev.c          |   20 +++++----
>  9 files changed, 121 insertions(+), 40 deletions(-)

pulled


