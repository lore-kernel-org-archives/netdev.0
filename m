From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns
 identify"
Date: Fri, 18 Jan 2013 01:00:23 +0000
Message-ID: <1358470823.15692.156.camel@deadeye.wl.decadent.org.uk>
References: <87a9u4q7k9.fsf@xmission.com>
	 <1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	 <87a9s772zw.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25600 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784Ab3ARBA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 20:00:27 -0500
In-Reply-To: <87a9s772zw.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 16:23 -0800, Eric W. Biederman wrote:
> Ben Hutchings <bhutchings@solarflare.com> writes:
> 
> > On Mon, 2012-11-26 at 17:16 -0600, Eric W. Biederman wrote:
[...]
> >> --- a/ip/ipnetns.c
> >> +++ b/ip/ipnetns.c
[...]
> >> +static int is_pid(const char *str)
> >> +{
> >> +	int ch;
> >> +	for (; (ch = *str); str++) {
> >> +		if (!isdigit(ch))
> >
> > ch must be cast to unsigned char before passing to isdigit().
> 
> isdigit is defined to take an int.  A legacy of the implicit casts in
> the K&R C days.  Casting to unsigned char would be pointless and silly.
[...]

It's not pointless.  This is explained in the very first line of the
description in the manual page...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
