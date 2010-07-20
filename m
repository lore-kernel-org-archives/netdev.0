From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] phy: add suspend/resume in the ic+
Date: Tue, 20 Jul 2010 08:24:21 -0700
Message-ID: <20100720082421.c8604af3.randy.dunlap@oracle.com>
References: <1279609954-30274-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:44749 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932441Ab0GTPYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 11:24:36 -0400
In-Reply-To: <1279609954-30274-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Jul 2010 09:12:34 +0200 Giuseppe CAVALLARO wrote:

> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/phy/icplus.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
> index 439adaf..3f2583f 100644
> --- a/drivers/net/phy/icplus.c
> +++ b/drivers/net/phy/icplus.c
> @@ -116,6 +116,8 @@ static struct phy_driver ip175c_driver = {
>  	.config_init	= &ip175c_config_init,
>  	.config_aneg	= &ip175c_config_aneg,
>  	.read_status	= &ip175c_read_status,
> +	.suspend	= genphy_suspend,
> +	.resume		= genphy_resume,
>  	.driver		= { .owner = THIS_MODULE,},
>  };
>  
> -- 

I was wondering how that works when CONFIG_PM is disabled, but I did a build
with it disabled and see that genphy_suspend and genphy_resume are always
built -- even when PM is disabled.  Interesting.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
