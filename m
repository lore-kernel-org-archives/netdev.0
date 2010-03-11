From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH] iproute2: detect iptables modules dir in configure.
Date: Thu, 11 Mar 2010 21:47:18 +0100
Message-ID: <1268340438.7707.4.camel@amd64.fatal.se>
References: <20100311190740.GA28425@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h12.telenor.se ([62.127.194.5]:57670 "EHLO
	smtprelay-h12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab0CKVO3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 16:14:29 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-h12.telenor.se (Postfix) with ESMTP id 47126248AE
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 21:48:12 +0100 (CET)
In-Reply-To: <20100311190740.GA28425@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On tor, 2010-03-11 at 20:07 +0100, Andreas Henriksson wrote:
[...]
> --- a/tc/Makefile
> +++ b/tc/Makefile
> @@ -77,6 +77,9 @@ TCLIB += tc_estimator.o
>  TCLIB += tc_stab.o
>  
>  CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB
> +ifneq ($(IPT_LIB_DIR),)
> +	CFLAGS += -DIPT_LIB_DIR="$(IPT_LIB_DIR)"
> +endif
>  

Sorry, I missed to escape the "'s above. I'll send a v2 in a few
seconds.



-- 
Regards,
Andreas Henriksson
