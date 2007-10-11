From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: iproute2: resend of patches from Debian.
Date: Thu, 11 Oct 2007 15:25:09 -0400
Message-ID: <20071011192509.GA4004@csclub.uwaterloo.ca>
References: <1192127132.4732.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:34937 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753158AbXJKTZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 15:25:10 -0400
Content-Disposition: inline
In-Reply-To: <1192127132.4732.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 08:25:32PM +0200, Andreas Henriksson wrote:
> Patch from debian iproute package.
> 
> diff -urNad iproute-20060323~/ip/iplink.c iproute-20060323/ip/iplink.c
> --- iproute-20060323~/ip/iplink.c	2006-03-22 00:57:50.000000000 +0100
> +++ iproute-20060323/ip/iplink.c	2006-09-08 21:07:14.000000000 +0200
> @@ -384,6 +384,10 @@
>  	}
>  
>  	if (newname && strcmp(dev, newname)) {
> +		if (strlen(newname) == 0) {
> +		    printf("\"\" is not valid device identifier\n",dev);
> +		    return -1;
> +		}
>  		if (do_changename(dev, newname) < 0)
>  			return -1;
>  		dev = newname;

Isn't that printf missing somewhere for the 'dev' argument to go?

--
Len Sorensen
