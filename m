From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 v4] ip: Simplify executing ip cmd within network
 ns
Date: Sat, 13 Dec 2014 10:58:03 +0200
Message-ID: <20141213085803.GA12446@angus-think.lan>
References: <1418422507-6635-1-git-send-email-vadim4j@gmail.com>
 <20141213082936.GA1849@nanopsycho.orion>
 <20141213084243.GA3284@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:60913 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966214AbaLMJH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 04:07:58 -0500
Received: by mail-la0-f45.google.com with SMTP id gq15so7361676lab.18
        for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 01:07:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141213084243.GA3284@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2014 at 10:42:43AM +0200, vadim4j@gmail.com wrote:
> On Sat, Dec 13, 2014 at 09:29:36AM +0100, Jiri Pirko wrote:
> > Fri, Dec 12, 2014 at 11:15:07PM CET, vadim4j@gmail.com wrote:
> > >From: Vadim Kochan <vadim4j@gmail.com>
> > >
> > >Added new '-netns' option to simplify executing following cmd:
> > >
> > >    ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> > >
> > >    to
> > >
> > >    ip -n[etns] NETNS OPTIONS COMMAND OBJECT
> > >
> > >e.g.:
> > >
> > >    ip -net vnet0 link add br0 type bridge
> > >    ip -n vnet0 link
> > >
> > >Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > 
> > 
> > This looks good. I'm still missing support in tc, bridge, etc. I think
> > it would be great to do this in the same patch/patchset.
> > 
>  I planned to do this in the future patches after this main
>  changes will be accepted. Actually adding this option to other
>  tools is trivial.
> 
>  Anyway may be I will re-send v5 with supporting of these tools if I will have time.
> 
>  Regards,

BTW, some tools already have '-n' option, so I think only '-net' can be
used in such cases.

Regards,
