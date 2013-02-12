From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: bridge interface initial carrier state
Date: Tue, 12 Feb 2013 22:06:05 +0100
Message-ID: <20130212210605.GA28929@minipsycho.orion>
References: <1360612915.8633.6.camel@dcbw.foobar.com>
 <20130211135836.2220ca68@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:47259 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347Ab3BLVGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 16:06:10 -0500
Received: by mail-ea0-f181.google.com with SMTP id i13so224942eaa.12
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 13:06:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130211135836.2220ca68@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 11, 2013 at 10:58:36PM CET, stephen@networkplumber.org wrote:
>On Mon, 11 Feb 2013 14:01:55 -0600
>Dan Williams <dcbw@redhat.com> wrote:
>
>> Hi,
>> 
>> I'm wondering if the initial carrier state of 'on' is intentional for a
>> bridge without ports; immediately after adding ports, the carrier is
>> recalculated and depends on the combined state of each port's carrier
>> and STP forwarding state.  So a userspace program attempting to decide
>> whether the bridge was usable or not has to look at both (a) how many
>> ports are available and (b) bridge carrier state, instead of just
>> looking at the bridge carrier state.
>> 
>> Dan
>
>It really should be off when no ports are present, but some initial startup
>scripts broke when it was that way.

How so? Can you give me an example of that script?
I think that any script should be able to handle a situation when carrier
of some device is down...


>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
