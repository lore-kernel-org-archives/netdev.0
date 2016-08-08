From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/2] devlink: write usage help messages to
 stderr
Date: Mon, 8 Aug 2016 08:56:54 -0700
Message-ID: <20160808085654.764550e2@xeon-e3>
References: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
	<20160723094659.06921b95@xeon-e3>
	<20160808071921.GA1944@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36422 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbcHHP4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 11:56:43 -0400
Received: by mail-pa0-f52.google.com with SMTP id pp5so114987860pac.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 08:56:42 -0700 (PDT)
In-Reply-To: <20160808071921.GA1944@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Aug 2016 09:19:21 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Sat, Jul 23, 2016 at 06:46:59PM CEST, stephen@networkplumber.org wrote:
> >On Fri, 22 Jul 2016 18:34:29 +0200
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >  
> >> From: Jiri Pirko <jiri@mellanox.com>
> >> 
> >> In order to not confuse reader, write help messages into stderr.
> >> 
> >> Signed-off-by: Jiri Pirko <jiri@mellanox.com>  
> >
> >This does make devlink consistent with other parts of iproute2.
> >But the most common coding standards, back to Unix, and GNU are
> >that help messages should go to stdout so that:
> >  $ ip -h | more
> >would work as expected.  
> 
> The thing is I wanted to make stdout only for json. Putting non-json
> help out there does not look correct to me. Is it?
> 

I applied both of these patches, just wanted to mention that iproute2 is not
following the GNU convention. At this point, it really doesn't matter, there
are arguments to be made for both behaviors.
