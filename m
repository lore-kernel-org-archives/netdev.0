From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Thu, 03 Sep 2015 11:03:54 +0200
Message-ID: <55E80CFA.7050408@iogearbox.net>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com> <20150826074959.48aea34c@as> <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com> <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com> <D20CE2AD.43744%Shaun.Crampton@metaswitch.com> <55E7907D.9000606@iogearbox.net> <D20DBEF2.437A0%Shaun.Crampton@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Marineau <michael.marineau@coreos.com>,
	Chuck Ebbert <cebbert.lkml@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Peter White <Peter.White@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60023 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbICJD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 05:03:58 -0400
In-Reply-To: <D20DBEF2.437A0%Shaun.Crampton@metaswitch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2015 10:13 AM, Shaun Crampton wrote:
...
> Is there anything I can do on a running system to help figure this out?
> Some sort of kernel equivalent to pmap to find out what module or device
> owns that chunk of memory?

Hmm, perhaps /proc/kallsyms could point to something. 0xffffffffa0087d81
and 0xffffffffa008772b could be from the same module, if any.
