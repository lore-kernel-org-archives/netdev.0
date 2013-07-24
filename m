From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/3 net-next] bridge: cleanup netpoll code
Date: Wed, 24 Jul 2013 21:07:40 +0200
Message-ID: <20130724190740.GB1632@minipsycho.orion>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:65191 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601Ab3GXTHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 15:07:44 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so444877eek.3
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 12:07:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 24, 2013 at 08:51:41PM CEST, stephen@networkplumber.org wrote:
>This started out with fixing a sparse warning, then I realized that
>the wrapper function br_netpoll_info could just be collapsed away
>by rolling it into the enable code.
>
>Also, eliminate unnecessary goto's
>
>Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
