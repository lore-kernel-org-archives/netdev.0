From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] ip: Add color output option
Date: Fri, 17 Apr 2015 19:26:54 +0200
Message-ID: <5531425E.1020206@iogearbox.net>
References: <20150417130202.GA29596@iki.fi> <20150417164402.GA7041@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aleksi.aalto@iki.fi
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40542 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbbDQR1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:27:03 -0400
In-Reply-To: <20150417164402.GA7041@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2015 06:44 PM, Alexei Starovoitov wrote:
> On Fri, Apr 17, 2015 at 04:02:02PM +0300, Mathias Nyman wrote:
>> It is hard to quickly find what you are looking for in the output of the ip
>> command. Color helps.
>>
>> This patch adds a '-c' flag to highlight these with individual colors:
>>    - interface name
>>    - ip addresse
>>    - mac addresse
>>    - up/down state
>
> idea looks good, but the patch doesn't apply at all, since it's
> whitespace damaged. Also there is no SOB.

You also might want to move the library bits into lib/ so that
not only ip but also other tools could use it in future. So -c
is neither taken in ip nor in tc or ss, that's good. ;)
