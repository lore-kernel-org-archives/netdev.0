From: Patrick McHardy <kaber@trash.net>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Fri, 18 Apr 2008 16:22:55 +0200
Message-ID: <4808AEBF.7040504@trash.net>
References: <20080417103858.0075236b@extreme>	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60563 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbYDROXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 10:23:00 -0400
In-Reply-To: <1208522727.4422.79.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote
> BTW, speaking of scripts and command line output changes (and to
> emphasize my earlier comments):
> A lot of people managing router configuration out there in the wild do
> write parsers that depend on how output looks like (typically a
> send/expect interaction)[1]. They invest time in writting such scripts.
> In an old job at one point, a customer was adamant they wouldnt buy our
> new super-dupper device merely because we changed the command output by
> iirc removing a ":" in one of them. Theyd have to rewrite things and go
> through whole regression testing.


Yes, that sucks (ran into the same problem with iproute in a
previous job). I added the ENV dump format to libnl a couple
of years ago (NAME=val), should be easy to add a set of simple
tools to get the information and export it in the environment.
