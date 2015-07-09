From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] iproute2: ipa: show switch id
Date: Thu, 9 Jul 2015 15:22:52 -0700
Message-ID: <20150709152252.068eb005@urahara>
References: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
	<20150708180510.54c90e74@urahara>
	<20150709060918.GB2270@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35436 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082AbbGIWWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:22:51 -0400
Received: by pactm7 with SMTP id tm7so157172409pac.2
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 15:22:51 -0700 (PDT)
In-Reply-To: <20150709060918.GB2270@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Jul 2015 08:09:18 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Thu, Jul 09, 2015 at 03:05:10AM CEST, stephen@networkplumber.org wrote:
> >On Wed,  8 Jul 2015 17:08:18 +0200
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >>  
> >> +	if (tb[IFLA_PHYS_SWITCH_ID]) {
> >> +		SPRINT_BUF(b1);
> >> +		fprintf(fp, "switchid %s ",
> >> +			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
> >> +				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
> >> +				      b1, sizeof(b1)));
> >> +	}
> >> +
> >
> >Ok, but why hex?
> 
> What else? It is an arbitrary byte array.

Ok I though it was a number.
