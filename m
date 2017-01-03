From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] net:mv88e6xxx: use g2 interrupt for 6097 chip
Date: Tue, 3 Jan 2017 17:28:15 +0100
Message-ID: <20170103162815.GC32450@lunn.ch>
References: <1483456720-9929-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@westermo.se
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41695 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964969AbdACQ2S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 11:28:18 -0500
Content-Disposition: inline
In-Reply-To: <1483456720-9929-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 04:18:40PM +0100, Volodymyr Bendiuga wrote:
> From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> 
> This chip needs MV88E6XXX_FLAG_G2_INT
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> index af54bae..431e954 100644
> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> @@ -566,6 +566,7 @@ enum mv88e6xxx_cap {
>  	(MV88E6XXX_FLAG_G1_ATU_FID |	\
>  	 MV88E6XXX_FLAG_G1_VTU_FID |	\
>  	 MV88E6XXX_FLAG_GLOBAL2 |	\
> + 	 MV88E6XXX_FLAG_G2_INT |	\

checkpatch is your friend:

$ ./scripts/checkpatch.pl volodymyr.bendiuga 
ERROR: code indent should use tabs where possible
#76: FILE: drivers/net/dsa/mv88e6xxx/mv88e6xxx.h:569:
+ ^I MV88E6XXX_FLAG_G2_INT |^I\$

WARNING: please, no space before tabs
#76: FILE: drivers/net/dsa/mv88e6xxx/mv88e6xxx.h:569:
+ ^I MV88E6XXX_FLAG_G2_INT |^I\$

WARNING: please, no spaces at the start of a line
#76: FILE: drivers/net/dsa/mv88e6xxx/mv88e6xxx.h:569:
+ ^I MV88E6XXX_FLAG_G2_INT |^I\$

total: 1 errors, 2 warnings, 0 checks, 7 lines checked

       Andrew
