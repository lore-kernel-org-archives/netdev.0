From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next] team: use strlcpy with ethtool_drvinfo fields
Date: Sat, 5 Jan 2013 14:17:31 +0100
Message-ID: <20130105131731.GA1594@minipsycho.orion>
References: <1357390390-16549-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755481Ab3AENRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 08:17:34 -0500
Content-Disposition: inline
In-Reply-To: <1357390390-16549-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 05, 2013 at 01:53:10PM CET, fbl@redhat.com wrote:
>The fields must be null-terminated.
>
>Signed-off-by: Flavio Leitner <fbl@redhat.com>
>---
> drivers/net/team/team.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 78c7d87..e27ac5c 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1747,8 +1747,8 @@ static const struct net_device_ops team_netdev_ops = {
> static void team_ethtool_get_drvinfo(struct net_device *dev,
> 				     struct ethtool_drvinfo *drvinfo)
> {
>-	strncpy(drvinfo->driver, DRV_NAME, 32);
>-	strncpy(drvinfo->version, UTS_RELEASE, 32);
>+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
>+	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
> }
> 
> static const struct ethtool_ops team_ethtool_ops = {
>-- 
>1.8.0.1
>


Acked-by: Jiri Pirko <jiri@resnulli.us>
