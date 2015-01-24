From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 07:36:40 -0500
Message-ID: <54C391D8.4040504@mojatatu.com>
References: <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia> <54C11094.2000807@mojatatu.com> <20150122151316.GB25797@casper.infradead.org> <54C11703.7030702@mojatatu.com> <20150122153727.GC25797@casper.infradead.org> <54C11ACC.5010005@mojatatu.com> <20150123101019.GF25797@casper.infradead.org> <20150123102421.GB2065@nanopsycho.orion> <20150123110821.GH25797@casper.infradead.org> <20150123113934.GD2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:55791 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431AbbAXMgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 07:36:44 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so1872499iec.0
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 04:36:43 -0800 (PST)
In-Reply-To: <20150123113934.GD2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 06:39, Jiri Pirko wrote:

> Maybe I did not express myself correctly. I do not care if this is
> exposed by rtnl or a separate genetlink. The issue still stands. And the
> issue is that the user have to use "the way A" to setup sw datapath and
> "the way B" to setup hw datapath. The preferable would be to have
> "the way X" which can be used to setup both sw and hw.
>
> And I believe that could be achieved. Consider something like this:
>
> - have cls_xflows tc classifier and act_xflows tc action as a wrapper
>    (or api) for John's work. With possibility for multiple backends. The
>    backend iface would looke very similar to what John has now.
> - other tc clses and acts will implement xflows backend
> - openvswitch datapath will implement xflows backend
> - rocker switch will implement xflows backend
> - other drivers will implement xflows backend
>
> Now if user wants to manipulate with any flow setting, he can just use
> cls_xflows and act_xflows to to that.
>
> This is very rough, but I just wanted to draw the picture. This would
> provide single entry to flow world manipulation in kernel, no matter if
> sw or hw.
>
> Thoughts?
>


Exactly my thinking as well.
I guess skipping a few emails helps.

cheers,
jamal
