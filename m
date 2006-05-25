From: Simon Oosthoek <wmc_simon@fastmail.fm>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Thu, 25 May 2006 12:53:28 +0200
Message-ID: <44758CA8.2030502@fastmail.fm>
References: <44731733.7000204@ti-wmc.nl>	 <20060523094324.11926fcc@localhost.localdomain>	 <447349A6.50105@fastmail.fm> <1148496189.5325.33.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	herman.elfrink@ti-wmc.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpq3.tilbu1.nb.home.nl ([213.51.146.202]:11219 "EHLO
	smtpq3.tilbu1.nb.home.nl") by vger.kernel.org with ESMTP
	id S965029AbWEYKxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 06:53:14 -0400
To: hadi@cyberus.ca
In-Reply-To: <1148496189.5325.33.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Essentially you are extending the broadcast domain i.e a bridge within
> on top of a bridge. I would question the scalability of such a beast
> in the presence of many nodes. Also take a look at some of the work
> Radia Perlman (who invented bridging really) is up to these days.
>
>   

Hi Jamal

I agree with your analysis, and recently I read an interesting interview 
with her (I think it was linked from slashdot, an interview with the 
"mother of the Internet ;-) I'm not sure her work (I don't exactly 
recall the specifics) is applicable to our problem though.

Regarding the scalability, I think it rather depends on the number of 
hops how usable FLAME is. I don't think it would scale well to a campus 
or city wide network, but in the case of a few mobile nodes, it has very 
little overhead both in bandwidth and delay.

Cheers

Simon

