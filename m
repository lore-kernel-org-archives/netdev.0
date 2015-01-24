From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 08:04:42 -0500
Message-ID: <54C3986A.9070105@mojatatu.com>
References: <20150123101019.GF25797@casper.infradead.org> <20150123102421.GB2065@nanopsycho.orion> <20150123110821.GH25797@casper.infradead.org> <20150123113934.GD2065@nanopsycho.orion> <20150123122838.GI25797@casper.infradead.org> <20150123134315.GF2065@nanopsycho.orion> <20150123140724.GJ25797@casper.infradead.org> <54C26A1F.6060603@gmail.com> <20150123155332.GJ2065@nanopsycho.orion> <20150123160058.GN25797@casper.infradead.org> <20150123161605.GN2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:40253 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbbAXNEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 08:04:45 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so1836165igb.3
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 05:04:45 -0800 (PST)
In-Reply-To: <20150123161605.GN2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not big on high fives but here's my +1
Excellent diagram below.

cheers,
jamal
On 01/23/15 11:16, Jiri Pirko wrote:
>
> As I wrote earlier, the value is that userspace can easily use single
> xflows api to take care of all ways to handle flows (ovs kernel dp,
> rocker, other device, u32 tc filter + actions, you name it)
>
>
>      my flow managing app
>            |
> uspc      |
>    --------|----------------------------------------------------
> krnl      |
>         tc xflows api
>            |  |  |
>            |  |  ---------------------------------------------------
>            |  |                                                    |
>            |  ------------------                                other xflows backend
>            |                   |
>       ovs xflows backend     rocker driver xflows backend
>            |                   |
>           ovs dp               |
> krnl	                      |
>    ----------------------------|--------------------------------
> hw                            |
>                             rocker switch
>
