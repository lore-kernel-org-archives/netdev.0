From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] iproute2: ipa: show switch id
Date: Wed, 8 Jul 2015 18:05:10 -0700
Message-ID: <20150708180510.54c90e74@urahara>
References: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36400 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbbGIBFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 21:05:00 -0400
Received: by pacgz10 with SMTP id gz10so67066914pac.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 18:05:00 -0700 (PDT)
In-Reply-To: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Jul 2015 17:08:18 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

>  
> +	if (tb[IFLA_PHYS_SWITCH_ID]) {
> +		SPRINT_BUF(b1);
> +		fprintf(fp, "switchid %s ",
> +			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
> +				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
> +				      b1, sizeof(b1)));
> +	}
> +

Ok, but why hex?
