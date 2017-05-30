From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V6 net-next iproute] ip: Add support for netdev events
 to monitor
Date: Tue, 30 May 2017 10:12:21 -0700
Message-ID: <20170530101221.1c5cb643@xeon-e3>
References: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
        <1495894476-9726-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34137 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdE3RM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 13:12:29 -0400
Received: by mail-pf0-f173.google.com with SMTP id 9so77886765pfj.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 10:12:29 -0700 (PDT)
In-Reply-To: <1495894476-9726-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 May 2017 10:14:36 -0400
Vladislav Yasevich <vyasevich@gmail.com> wrote:

>  
> +static const char *netdev_events[] = {"NONE",
> +				      "REBOOT",
> +				      "FEATURE CHANGE",
> +				      "BONDING FAILOVER",
> +				      "NOTIFY PEERS",
> +				      "RESEND IGMP",
> +				      "BONDING OPTION"};

Overall this looks fine, I will pickup the if_link.h from net-next.

One stylistic change.

Please add simple line break, and initialize by value:

static const char *netdev_events[] = {
	[IFLA_EVENT_NONE]	= "NONE",
...

Do you want some prefix or bounding around the event output?
Also a little concerned that the output format change may break some program
could the new output be at the end of the line?
