From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Source routing without rules?
Date: Tue, 27 Aug 2013 18:29:57 -0700
Message-ID: <CALCETrUFbxsnts6Z0_rko+s6N+q5ZtzS8y+FBQW8D-ctO+FAmA@mail.gmail.com>
References: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com>
 <521D4AFD.2000102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:52827 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab3H1BaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 21:30:18 -0400
Received: by mail-ve0-f170.google.com with SMTP id 15so3884180vea.29
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 18:30:17 -0700 (PDT)
In-Reply-To: <521D4AFD.2000102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 5:57 PM, Brian Haley <brian.haley@hp.com> wrote:
> On 08/27/2013 08:16 PM, Andy Lutomirski wrote:
>> I'm about to implement a trivial source routing policy for the third
>> time, and this is IMO stupid.  I want to have two routes to a network.
>>  Each route should specify a src, and, if the flow matches the src,
>> then that route should win.
>>
>> The rules that don't work are:
>>
>> ip route add <net> via <gw1> dev <dev1> metric 0
>> ip route add <net> via <gw2> dev <dev2> src <dev2addr> metric 10
>>
>> Even if I bind a socket to dev2addr, the outgoing packets go out dev1
>> to gw1.  This is exactly what I don't want to have happen.
>
> Look at this page on routing rules:
>
> http://lartc.org/howto/lartc.rpdb.html

Been there, done that.  I want to do this in a way that's easy and
scalable, and rules are neither.

--Andy
