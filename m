From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] ethtool: Dump eeprom info for soldered on modules
Date: Tue, 1 Sep 2015 10:52:25 +0200
Message-ID: <20150901085225.GB26624@lunn.ch>
References: <1439690718-10040-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42993 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbbIAJAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 05:00:03 -0400
Content-Disposition: inline
In-Reply-To: <1439690718-10040-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 16, 2015 at 04:05:18AM +0200, Andrew Lunn wrote:
> Modules which are soldered onto the motherboard may also use the sff8079
> EEPROM format. Dump these in the same way as SFP modules.

Hi Ben

I posted this patch two weeks ago. Since this is my first ethtool
patch, i've no idea what your response time usually is. Do i need to
repost? Send a gentle reminder? Or just wait a bit longer?

Thanks
	Andrew

> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  sfpid.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/sfpid.c b/sfpid.c
> index b1a5044..0b5cd62 100644
> --- a/sfpid.c
> +++ b/sfpid.c
> @@ -401,7 +401,7 @@ static void sff8079_show_options(const __u8 *id)
>  void sff8079_show_all(const __u8 *id)
>  {
>  	sff8079_show_identifier(id);
> -	if ((id[0] == 0x03) && (id[1] == 0x04)) {
> +	if (((id[0] == 0x02) || (id[0] == 0x03)) && (id[1] == 0x04)) {
>  		sff8079_show_ext_identifier(id);
>  		sff8079_show_connector(id);
>  		sff8079_show_transceiver(id);
> -- 
> 2.1.4
> 
