From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM Doc]: aevent description
Date: Thu, 20 Apr 2006 12:12:39 -0700 (PDT)
Message-ID: <20060420.121239.105700725.davem@davemloft.net>
References: <1144933208.5262.9.camel@jzny2>
	<20060414.150536.04415810.davem@davemloft.net>
	<1145530725.5169.12.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hidden@balabit.hu,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39902
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750866AbWDTTMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 15:12:48 -0400
To: hadi@cyberus.ca
In-Reply-To: <1145530725.5169.12.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 20 Apr 2006 06:58:45 -0400

> On Fri, 2006-14-04 at 15:05 -0700, David S. Miller wrote:
> > From: jamal <hadi@cyberus.ca>
> > Date: Thu, 13 Apr 2006 09:00:08 -0400
> > 
> > > There is dependency on the previous patch i sent since the issue that
> > > patch fixes is assumed in this text description. It would be a good
> > > idea to apply at the same time as the other.
> > 
> > Applied, after fixing 28 lines containing trailing whitespace :-)
> 
> yikes ;->
> Ok, so how do i avoid this in the future? Note, this was a _brand new_
> file, so it is a little bizarre.

This command:

	git apply --check --whitespace=error-all $1

will spit out errors if your patch adds trailing whitespace
or will not apply cleanly to the current GIT tree.
