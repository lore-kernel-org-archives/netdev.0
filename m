From: David Miller <davem@davemloft.net>
Subject: Re: [net, 3/6] net: korina: increase tx/rx ring sizes
Date: Tue, 17 Jan 2017 14:08:31 -0500 (EST)
Message-ID: <20170117.140831.246422739371129394.davem@davemloft.net>
References: <1484674356-22363-1-git-send-email-roman@advem.lv>
        <20170117.125844.253301507252169868.davem@davemloft.net>
        <CACiydbLuVf_jsWor6-OJmwQhxfwd=dzBDnDQnJrp3owf8qCkQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leroi.lists@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdAQTId (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:08:33 -0500
In-Reply-To: <CACiydbLuVf_jsWor6-OJmwQhxfwd=dzBDnDQnJrp3owf8qCkQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Yeryomin <leroi.lists@gmail.com>
Date: Tue, 17 Jan 2017 20:27:57 +0200

> On 17 January 2017 at 19:58, David Miller <davem@davemloft.net> wrote:
>> From: Roman Yeryomin <leroi.lists@gmail.com>
>> Date: Tue, 17 Jan 2017 19:32:36 +0200
>>
>>> Having larger ring sizes almost eliminates rx fifo overflow, thus improving performance.
>>> This patch reduces rx overflow occurence by approximately 1000 times (from ~25k down to ~25 times per 3M frames)
>>
>> Those numbers don't mean much without full context.
>>
>> What kind of system, what kind of traffic, and over what kind of link?
> 
> MIPS rb532 board, TCP iperf3 test over 100M link, NATed speed ~55Mbps.
> I can do more tests and provide more precise numbers, if needed.

Provide this information in the commit message on your respin of this patch
series after you've addressed all of the other feedback, don't tell me :-)
