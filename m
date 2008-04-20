From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Sun, 20 Apr 2008 07:48:48 -0400
Message-ID: <1208692128.12249.26.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>
	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>
	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>
	 <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost>
	 <480A21AF.1040405@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:12784 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbYDTLsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 07:48:53 -0400
Received: by an-out-0708.google.com with SMTP id d31so369501and.103
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 04:48:52 -0700 (PDT)
In-Reply-To: <480A21AF.1040405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-19-04 at 18:45 +0200, Patrick McHardy wrote:

> I imagine something like this:
> 
> # nl-link-dump env eth0
> 
> LINK_NAME=eth0
> LINK_IFINDEX=2
> LINK_LLADDR=.....
> LINK_OPERSTATE=...
> 
> and so on. You could then do something like this:
> 
> export $(nl-link-dump env eth0)
> 
> and use $LINK_... in your scripts.
> 

Clever. That would certainly help in portability; i will take a closer
look on what you did for libnl and see how well it applies for iproute2.

Stephen, I have some cycles today - I am going to assume no-response
from you implies ok on the change i sent earlier - so i will work on
adding additional changes on top of the one i sent earlier to fixup the
pretty printing (which is not as serious a regression IMO as breakage of
the output).

cheers,
jamal

