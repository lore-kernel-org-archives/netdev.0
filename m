From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 07:34:41 -0500
Message-ID: <54C39161.9030300@mojatatu.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150122125246.GA4486@salvia> <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia> <54C11094.2000807@mojatatu.com> <20150122151316.GB25797@casper.infradead.org> <54C11703.7030702@mojatatu.com> <20150122153727.GC25797@casper.infradead.org> <20150122164951.GA3417@salvia> <20150122174445.GD25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:51644 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbbAXMeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 07:34:44 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar1so1829698iec.6
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 04:34:43 -0800 (PST)
In-Reply-To: <20150122174445.GD25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 12:44, Thomas Graf wrote:
> On 01/22/15 at 05:49pm, Pablo Neira Ayuso wrote:

>
> You can achieve the exact same thing with an out of tree tc action,
> classifier or even a new link type. Nothing prevents an out of tree
> driver to register a new rtnetlink link type and do vendor specific
> crap.
>

They are not the same. The API lowers the barrier immensely; refer to
my response to John. And we are actually handing it to them.

 From an equivalance perspective:
Youd have to convince Dave to allow all those TOE vendors to get in
with their direct hardware APIs (if those guys are still around).

cheers,
jamal
