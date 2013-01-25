From: Pavel Simerda <psimerda@redhat.com>
Subject: Re: [patch net-next V2] bond: have random dev address by default
 instead of zeroes
Date: Fri, 25 Jan 2013 14:42:01 -0500 (EST)
Message-ID: <1136817119.4224160.1359142921330.JavaMail.root@redhat.com>
References: <22106.1359138692@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, dcbw@redhat.com,
	Jiri Pirko <jiri@resnulli.us>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:47435 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284Ab3AYTnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 14:43:10 -0500
In-Reply-To: <22106.1359138692@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "Jay Vosburgh" <fubar@us.ibm.com>
> To: "Pavel Simerda" <psimerda@redhat.com>
> Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net, stephen@networkplumber.org, dcbw@redhat.com,
> "Jiri Pirko" <jiri@resnulli.us>
> Sent: Friday, January 25, 2013 7:31:32 PM
> Subject: Re: [patch net-next V2] bond: have random dev address by default instead of zeroes
> 
> Pavel Simerda <psimerda@redhat.com> wrote:
> 
> >----- Original Message -----
> >> From: "Jay Vosburgh" <fubar@us.ibm.com>
> >> but I don't think it should be changed.
> >
> >Just a short question. Is there any reason for bonding interfaces to
> >behave differently from bridging interfaces in this respect?
> 
> 	To clarify, what I don't think should change is that a manually
> set MAC on the bonding master should override the automatic copy of
> the
> first slave's MAC to the bonding master.  The fail_over_mac active
> and
> follow settings are an exception to this, but those are special cases
> for unusual network hardware.
> 
> 	As for the random MAC vs. zero MAC, I've always thought that the
> all zero MAC was a clear indicator that the device (the bonding
> master
> in this case) was not in a usable state (in the sense that it could
> not
> send or receive actual traffic).  It's not a really big deal, though,
> so

Thanks for clarification.
> if the trend these days is for everything to have a MAC all the time,
> that's fine, as long as doing so doesn't break anything.
> 
> 	I think the patch under discussion should be fine with the
> addition of the last notifier call previously discussed.  Some
> documentation updates would be nice, too.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
> 
