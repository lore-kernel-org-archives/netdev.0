From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] pktgen: introduce xmit_mode 'rx_inject'
Date: Wed, 06 May 2015 12:17:02 +0200
Message-ID: <5549EA1E.6040708@iogearbox.net>
References: <20150505202730.8715.48527.stgit@ivy>	<20150505202959.8715.51882.stgit@ivy>	<55499996.2090308@plumgrid.com> <20150506072440.7afb2c44@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37289 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbEFKRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 06:17:10 -0400
In-Reply-To: <20150506072440.7afb2c44@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2015 07:24 AM, Jesper Dangaard Brouer wrote:
> On Tue, 05 May 2015 21:33:26 -0700
> Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On 5/5/15 1:30 PM, Jesper Dangaard Brouer wrote:
>>>
>>> Introduce xmit_mode 'rx_inject' for pktgen which generates the packets
>>> using familiar pktgen commands, but feeds them into
>>> netif_receive_skb() instead of ndo_start_xmit().
>> ...
>>> pgset "xmit_mode rx_inject"
>>
>> I think 'xmit_mode rx_inject' would make native english speaker cringe,
>> since it's saying 'transmit mode is receive' ... but I don't mind :)
>
> Yes, I know. Like Daniel suggested, I considered only calling it "rx"
> but it made me cringe for this exact reason, thus I extended it with
> "inject".  I'm flexible with the name of this...

I don't mind how you name it eventually. ;) 'xmit_mode' I think is
good, and rx|tx would be symmetric. I believe you don't like "rx" due
to these two out-of-tree pktgen projects you mentioned having rx
capabilities. Is that correct? From my perspective, it would be more
worth however to improve packet sockets and eBPF that could already
do the same thing instead of a dedicated possible pktgen receive/
capturing device for such analysis. Anyway, I can also live with a
rx_inject.

Cheers,
Daniel
