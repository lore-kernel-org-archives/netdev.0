From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] team: use strlcpy with ethtool_drvinfo fields
Date: Sat, 5 Jan 2013 14:11:17 +0000
Message-ID: <1357395077.4324.5.camel@deadeye.wl.decadent.org.uk>
References: <1357390390-16549-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jpirko@redhat.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64662 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3AEOLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 09:11:25 -0500
In-Reply-To: <1357390390-16549-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-05 at 10:53 -0200, Flavio Leitner wrote:
> The fields must be null-terminated.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  drivers/net/team/team.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 78c7d87..e27ac5c 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1747,8 +1747,8 @@ static const struct net_device_ops team_netdev_ops = {
>  static void team_ethtool_get_drvinfo(struct net_device *dev,
>  				     struct ethtool_drvinfo *drvinfo)
>  {
> -	strncpy(drvinfo->driver, DRV_NAME, 32);
> -	strncpy(drvinfo->version, UTS_RELEASE, 32);
> +	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
> +	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
>  }
>  
>  static const struct ethtool_ops team_ethtool_ops = {

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
