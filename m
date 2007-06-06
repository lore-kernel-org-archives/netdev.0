From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Module for ip utility to support veth device
Date: Wed, 06 Jun 2007 17:18:59 +0200
Message-ID: <4666D063.3060402@trash.net>
References: <4666CEAA.8010903@openvz.org> <4666CFFF.9020204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56022 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761075AbXFFPT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 11:19:27 -0400
In-Reply-To: <4666CFFF.9020204@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 5170419..6975990 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -287,7 +287,7 @@ static int iplink_modify(int cmd, unsign
>  			 strlen(type));
>  
>  		lu = get_link_type(type);
> -		if (lu) {
> +		if (lu && argc) {
>  			struct rtattr * data = NLMSG_TAIL(&req.n);
>  			addattr_l(&req.n, sizeof(req), IFLA_INFO_DATA, NULL, 0);


I've folded this part into my iproute patch, thanks.
