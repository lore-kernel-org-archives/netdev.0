From: Tushar Shinde <mtk.tushar@gmail.com>
Subject: Re: IPv6 Policy based routing not working.
Date: Wed, 27 Aug 2014 11:32:55 +0530
Message-ID: <CABQpAL4zbeqX4X1Kuzw-+FOppmYx7VzTzJn9OMLyYVBdS0Bz9w@mail.gmail.com>
References: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
	<1409090482.1152.8.camel@localhost>
	<CABQpAL4J7D704iw8Qj9SNDxW8E1P7Mw+KONUapZY6_LdoHkEYw@mail.gmail.com>
	<1409118957.11976.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:50669 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525AbaH0GC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 02:02:56 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so5240882wiw.12
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 23:02:55 -0700 (PDT)
In-Reply-To: <1409118957.11976.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So do we need to always use ipv6 address to bind unlike ipv4?

Tushar

On Wed, Aug 27, 2014 at 11:25 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mi, 2014-08-27 at 10:24 +0530, Tushar Shinde wrote:
>> Hi Hannes,
>>
>> Thank you for reply.
>>
>> I tested it will 2 kernels 2.6.32-431.11.2.el6.x86_64, and ubuntu
>> 14.04 kernel 3.13.
>>
>> ping6 -I <IPv6 src ip> <dest> is working. I also verified ssh with -b working.
>>
>> So my question is, is it necessary to give bind address to make source
>> based routing work? why don't it select ip address of given bind
>> interface? Because of this SO_BINDTODEVICE may not work as expected.
>
> Hmm, not sure, but last time I looked ping6 did not do SO_BINDTODEVICE
> at all and I doubt it changed. It merely sets outgoing interface index
> in cmsg PKTINFO data.
>
> Semantically those are not the same. Interface index on global
> destination addresses is only advisory, no strict routing lookup will be
> done.
>
> Bye,
> Hannes
>
>
