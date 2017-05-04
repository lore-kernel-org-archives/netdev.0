From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 09:43:56 -0700
Message-ID: <20170504094356.66590a9a@xeon-e3>
References: <20170503235638.31116-1-stephen@networkplumber.org>
        <590AF624.6090808@iogearbox.net>
        <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
        <20170504.104103.1628291573330660235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34403 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753246AbdEDQn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:43:59 -0400
Received: by mail-pg0-f46.google.com with SMTP id v1so11371811pgv.1
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 09:43:59 -0700 (PDT)
In-Reply-To: <20170504.104103.1628291573330660235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 May 2017 10:41:03 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: David Ahern <dsahern@gmail.com>
> Date: Thu, 4 May 2017 08:27:35 -0600
> 
> > On 5/4/17 3:36 AM, Daniel Borkmann wrote:  
> >> What is the clear benefit/rationale of outsourcing this to
> >> libmnl? I always was the impression we should strive for as little
> >> dependencies as possible?  
> > 
> > +1  
> 
> Agreed, all else being equal iproute2 should be as self contained
> as possible since it is such a fundamental tool.

Sorry, the old netlink code is more difficult to understand than libmnl.
Having dependency on a library is not a problem. There already is
an alternative implementation of ip commands in busybox for those
people trying to work in small environments.
