From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH][RESEND 3] IPv6: 6rd tunnel mode
Date: Tue, 22 Sep 2009 21:47:05 -0400
Message-ID: <4AB97E19.3030000@hp.com>
References: <20090922220251.GA22874@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexandre Cassen <acassen@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:9896 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753576AbZIWBrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 21:47:03 -0400
In-Reply-To: <20090922220251.GA22874@lnxos.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexandre Cassen wrote:
>
> +/* 6RD parms */
> +struct ip_tunnel_6rd {
> +	struct in6_addr		addr;
> +	__u8			prefixlen;
> +};

Are you sure you're not going to want to add anything to this struct in
the future like ifindex or flags?  Since it's part of the API you'd want
to do that now.

-Brian
