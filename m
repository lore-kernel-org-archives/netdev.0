From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: ifconfig doesn't show assignment ip-addresses
Date: Tue, 10 Dec 2013 12:48:48 +0100
Message-ID: <20131210114847.GA20146@omega>
References: <20131209153238.GA10317@omega>
 <20131210105741.GA2469@minipsycho.orion>
 <20131210110648.GA18196@omega>
 <20131210114339.GB2469@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33048 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016Ab3LJLs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 06:48:56 -0500
Received: by mail-wi0-f178.google.com with SMTP id bz8so5084081wib.17
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 03:48:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131210114339.GB2469@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 12:43:39PM +0100, Jiri Pirko wrote:
> Tue, Dec 10, 2013 at 12:06:49PM CET, alex.aring@gmail.com wrote:
> >Hi,
> >
> >thanks for your reply.
> >
> >On Tue, Dec 10, 2013 at 11:57:41AM +0100, Jiri Pirko wrote:
> >> Mon, Dec 09, 2013 at 04:32:39PM CET, alex.aring@gmail.com wrote:
> >> >Hi,
> >> >
> >> >On current net-next with a lowpan interface created with:
> >> >
> >> >ip link add link wpan0 name lowpan0 type lowpan
> >> >
> >> >I don't see any ipv6 addresses in ifconfig anymore. The addresses exist,
> >> >because I can ping my device.
> >> 
> >> 
> >> Can you see the address in "ip a" ? Would you send me output of
> >> "ifconfig" and "ip a" please? Is this a problem for lowpan only or do
> >> you see this with other device types as well?
> >> 
> 
> The problem is that ifconfig parses /proc/net/if_inet6 which changed
> flag format from 2 hexa chars to 3.
> I will send revert for this change in couple of minutes.
> 

ah, nice to known. Thanks!

What would be a proper solution to add a u32 flag property? Or we never
should change this, because we want backwards compatibility?

- Alex
