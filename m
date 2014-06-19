From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] of: mdio: fixup of_phy_register_fixed_link parsing
 of new bindings
Date: Fri, 20 Jun 2014 01:34:27 +0400
Message-ID: <53A35763.4020904@cogentembedded.com>
References: <53A33AD0.2060200@cogentembedded.com> <1403213337-14303-1-git-send-email-rretanubun.work@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, thomas.petazzoni@free-electrons.com
To: Richard Retanubun <rretanubun.work@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:64470 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964833AbaFSVeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 17:34:19 -0400
Received: by mail-la0-f45.google.com with SMTP id hr17so1824191lab.4
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 14:34:18 -0700 (PDT)
In-Reply-To: <1403213337-14303-1-git-send-email-rretanubun.work@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/20/2014 01:28 AM, Richard Retanubun wrote:

> Fixes commit 3be2a49e5c08 ("of: provide a binding for fixed link PHYs")

> Fix the parsing of the new fixed link dts bindings for duplex,
> pause, and asym_pause by using the correct device node pointer.

> Signed-off-by: Richard Retanubun <rretanubun.work@gmail.com>
> ---
> v2: Clean up code indentation. Thanks Sergei!

    Unfortunately, you've misunderstood me. :-/

>   drivers/of/of_mdio.c | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 7700ddc..b5f7817 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -290,11 +290,13 @@ int of_phy_register_fixed_link(struct device_node *np)
>   	fixed_link_node = of_get_child_by_name(np, "fixed-link");
>   	if (fixed_link_node) {
>   		status.link = 1;
> -		status.duplex = of_property_read_bool(np, "full-duplex");
> +		status.duplex = of_property_read_bool(fixed_link_node,
> +							"full-duplex");

    When I said that continuation line should start under 'fixed_link_node', I 
meant it should start right under first letter of this name, after (. You 
don't need to use tabs only when indenting the networking code, appropriate 
number of spaces after tabs is OK.

WBR, Sergei
