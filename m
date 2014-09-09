From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next v4 0/3] Refactor vxlan and l2tp to use common UDP
 tunnel APIs
Date: Tue, 9 Sep 2014 00:49:11 -0700
Message-ID: <CACzMAJL76dm1uwttMG2Z8rB3oUA_j05Jd2iKUWdFGqsFE4OJQw@mail.gmail.com>
References: <1409817462-7957-1-git-send-email-azhou@nicira.com>
	<20140905.171942.713956165843587914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:41278 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932092AbaIIHtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 03:49:12 -0400
Received: by mail-oi0-f49.google.com with SMTP id g201so10736269oib.36
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 00:49:11 -0700 (PDT)
In-Reply-To: <20140905.171942.713956165843587914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David, thanks for the review. I have fixed the indentations for
functions as you pointed out.

I also plan to improve ifdefs in udp_tunnel.c in the next patch per
your suggestion.

However, vxlan.c and l2tp_core.c have many pre-exsisting ifdefs
(basically for CONFIG_IPV6). I am not sure if it make sense to remove
-- The readability may only improve marginally, if at all.  My patch
does not add new ones, but may move existing ones around as part of
re-factoring, I don't plan to make more changes to ,u current patch
series.

In case you still feel strongly we should clean up existing ifdefs
from vxlan.c and l2tp_core.c, I'd suggest that we work on separate
patches to deal with them. Does this make sense?

Andy

On Fri, Sep 5, 2014 at 5:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Zhou <azhou@nicira.com>
> Date: Thu,  4 Sep 2014 00:57:39 -0700
>
>> Andy Zhou (3):
>>   udp-tunnel: Expand UDP tunnel APIs
>>   vxlan: Refactor vxlan driver to make use of the common UDP tunnel
>>     functions.
>>   l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
>>        functions
>
> Way too many ifdefs in *.c code, and your indentation is not correct.
> For function calls that span multiple lines, you must start the second
> and subsequent lines exactly at the first column after the openning
> parenthesis of the first line.  You must use the appropriate number of
> TAB and SPACE characters necessary to do so.  If you are indenting these
> lines only using TAB characters, you are very likely doing it wrong.
>
> Thanks.
