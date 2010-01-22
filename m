From: greg@enjellic.com
Subject: Re: Global IPV6 auto-configuration does not work as expected.
Date: Fri, 22 Jan 2010 13:01:50 -0600
Message-ID: <201001221901.o0MJ1oLk016090@wind.enjellic.com>
References: <davem@davemloft.net>
Reply-To: greg@enjellic.com
Cc: brian.haley@hp.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, greg@enjellic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wind.enjellic.com ([209.243.13.15]:51274 "EHLO
	wind.enjellic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756161Ab0AVTCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 14:02:00 -0500
In-Reply-To: David Miller <davem@davemloft.net>
       "Re: Global IPV6 auto-configuration does not work as expected." (Jan 19, 12:35pm)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 19, 12:35pm, David Miller wrote:
} Subject: Re: Global IPV6 auto-configuration does not work as expected.
> From: greg@enjellic.com

Hi, hope the day is going well for everyone.

> Date: Tue, 19 Jan 2010 14:34:00 -0600
> 
> > That would only be effective with a modular implementation of ipv6.
> > As I noted above these are completely static kernels.

> That's incorrect, you can still set the parameter if ipv6 is
> built statically into your kernel.
> 
> You can set "module" parameters on the kernel command line by
> saying, f.e., "ipv6.autoconf=0"

Dave to the rescue.... :-)

That option works perfectly well.  I had actually hacked the kernel
source to set the default but the kernel command-line is less
invasive.

Thanks to everyone for the input.

Best wishes for a pleasant week.

}-- End of excerpt from David Miller

As always,
Dr. G.W. Wettstein, Ph.D.   Enjellic Systems Development, LLC.
4206 N. 19th Ave.           Specializing in information infra-structure
Fargo, ND  58102            development.
PH: 701-281-1686
FAX: 701-281-3949           EMAIL: greg@enjellic.com
------------------------------------------------------------------------------
"Boy, it must not take much to make a phone work.  Looking at
 everthing else here it must be the same way with the INTERNET."
                                -- Francis 'Fritz' Wettstein
