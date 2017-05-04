From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 04 May 2017 10:41:03 -0400 (EDT)
Message-ID: <20170504.104103.1628291573330660235.davem@davemloft.net>
References: <20170503235638.31116-1-stephen@networkplumber.org>
        <590AF624.6090808@iogearbox.net>
        <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752997AbdEDOlI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 10:41:08 -0400
In-Reply-To: <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 4 May 2017 08:27:35 -0600

> On 5/4/17 3:36 AM, Daniel Borkmann wrote:
>> What is the clear benefit/rationale of outsourcing this to
>> libmnl? I always was the impression we should strive for as little
>> dependencies as possible?
> 
> +1

Agreed, all else being equal iproute2 should be as self contained
as possible since it is such a fundamental tool.
