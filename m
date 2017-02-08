From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next repost2] tc: flower: use correct type
 when calling flower_icmp_attr_type
Date: Wed, 8 Feb 2017 11:39:06 -0800
Message-ID: <20170208113906.587df2a2@xeon-e3>
References: <1486555471-19120-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36316 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdBHTrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:47:52 -0500
Received: by mail-io0-f181.google.com with SMTP id j13so124778705iod.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 11:46:47 -0800 (PST)
In-Reply-To: <1486555471-19120-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Feb 2017 13:04:31 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Use enum flower_icmp_field rather than bool as type of third parameter
> when calling flower_icmp_attr_type.
> 
> Fixes: eb3b5696f163 ("tc: flower: support matching on ICMP type and code")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
> * Reposted a second time due to send-mail set-up error
> * Reposted after breaking out of a larger patch-set
> * This should not have a run-time affect assuming both false and
>   FLOWER_ICMP_FIELD_TYPE - the first value of enum flower_icmp_field -
>   are zero.

Applied to net-next
