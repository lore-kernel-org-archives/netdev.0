From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Tue, 16 May 2017 09:36:25 -0700
Message-ID: <20170516093625.178caf3f@xeon-e3>
References: <20170503235638.31116-1-stephen@networkplumber.org>
        <590AF624.6090808@iogearbox.net>
        <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
        <20170504.104103.1628291573330660235.davem@davemloft.net>
        <20170504094356.66590a9a@xeon-e3>
        <20170504204318.GB21130@orbyte.nwl.cc>
        <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, David Miller <davem@davemloft.net>,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34089 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdEPQgd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:36:33 -0400
Received: by mail-pg0-f42.google.com with SMTP id u28so79026937pgn.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 09:36:33 -0700 (PDT)
In-Reply-To: <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 May 2017 19:29:57 -0600
David Ahern <dsahern@gmail.com> wrote:

> On 5/4/17 2:43 PM, Phil Sutter wrote:
> > So in summary, given that very little change happens to iproute2's
> > internal libnetlink, I don't see much urge to make it use libmnl as
> > backend. In my opinion it just adds another potential source of errors.
> > 
> > Eventually this should be a maintainer level decision, though. :)  
> 
> What is the decision on this?

I am waiting for a longer before committing anything. This was to allow
for a wider range of distribution maintainer feedback.

The most likely outcome is that for 4.12 is to use libmnl for extended ack.
And continue to support building without mnl with loss of functionality.

As far as conversion of all of iproute2 to libmnl. I have better things
to do... But for new functionality like extended ack, devlink, tipc, using
libmnl is easy, safe and it works well. I will continue to not accept
new  code that depends on the other library (libnl). That has come up
a couple of times.
