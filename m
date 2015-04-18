From: Mathias Nyman <m.nyman@iki.fi>
Subject: Re: [PATCH net-next] ip: Add color output option
Date: Sat, 18 Apr 2015 13:22:58 +0300
Message-ID: <20150418102258.GA7005@iki.fi>
References: <20150417130202.GA29596@iki.fi>
 <20150417164402.GA7041@Alexeis-MBP.westell.com>
 <5531425E.1020206@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, aleksi.aalto@iki.fi
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:35576 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbbDRKXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2015 06:23:03 -0400
Content-Disposition: inline
In-Reply-To: <5531425E.1020206@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-17 19:26+0200, Daniel Borkmann wrote:
>On 04/17/2015 06:44 PM, Alexei Starovoitov wrote:
>>On Fri, Apr 17, 2015 at 04:02:02PM +0300, Mathias Nyman wrote:
>>>It is hard to quickly find what you are looking for in the output of the ip
>>>command. Color helps.
>>>
>>>This patch adds a '-c' flag to highlight these with individual colors:
>>>   - interface name
>>>   - ip addresse
>>>   - mac addresse
>>>   - up/down state
>>
>>idea looks good, but the patch doesn't apply at all, since it's
>>whitespace damaged. Also there is no SOB.

First timer; the v2 should fix these.


>You also might want to move the library bits into lib/ so that
>not only ip but also other tools could use it in future. So -c
>is neither taken in ip nor in tc or ss, that's good. ;)
>

I don't understand what you mean by "-c is neither taken in ip nor in
tc or ss". I am not finding a common place where to handle the -color
flag for ip, tc and ss, if that's what you mean. The common color.c is
under lib/ in v2 though.


Thanks for super fast feedback guys!
