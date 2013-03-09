From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/5] team: make local function static
Date: Sat, 9 Mar 2013 13:07:50 +0100
Message-ID: <20130309120750.GA1914@minipsycho.orion>
References: <20130308190739.260966567@vyatta.com>
 <20130308190809.432176649@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:33703 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522Ab3CIMIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 07:08:00 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so1513518eek.13
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 04:07:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130308190809.432176649@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 08, 2013 at 08:07:43PM CET, shemminger@vyatta.com wrote:
>Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>
>--- a/drivers/net/team/team.c	2013-03-06 15:30:50.195924953 -0800
>+++ b/drivers/net/team/team.c	2013-03-08 10:34:45.446144458 -0800
>@@ -503,9 +503,9 @@ static bool team_dummy_transmit(struct t
> 	return false;
> }
> 
>-rx_handler_result_t team_dummy_receive(struct team *team,
>-				       struct team_port *port,
>-				       struct sk_buff *skb)
>+static rx_handler_result_t team_dummy_receive(struct team *team,
>+					      struct team_port *port,
>+					      struct sk_buff *skb)
> {
> 	return RX_HANDLER_ANOTHER;
> }
>
>

Acked-by: Jiri Pirko <jiri@resnulli.us>

Thanks Stephen.
