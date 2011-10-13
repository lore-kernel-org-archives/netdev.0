From: Olaf van der Spek <ml@vdspek.org>
Subject: Re: Seamless Service Restart / Port Takeover
Date: Thu, 13 Oct 2011 11:56:04 +0200
Message-ID: <CAGVGHmugM7Ta3mafe1V5n76QZrZzCryMo3kr=XPfb4knmPP_hg@mail.gmail.com>
References: <CAGVGHmuVnsw4mdsxO=93yaYRgGaj20gR0+nNB_iaS=nTM_BThw@mail.gmail.com>
	<4E95CAD8.3050405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42365 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab1JMJ4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 05:56:05 -0400
Received: by vcbgb30 with SMTP id gb30so1337183vcb.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 02:56:04 -0700 (PDT)
In-Reply-To: <4E95CAD8.3050405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 7:14 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 10/12/2011 09:53 AM, Olaf van der Spek wrote:
>>
>> Hi,
>>
>> When restarting a service, a webserver for example, you'd like this to
>> be seamless for clients. Often, first a signal is send to the old
>> process to close listening sockets, then the new process is started.
>> This has both a race condition (sometimes 'avoided' with a sleep in
>> between) and service interruption.
>> Wouldn't it be possible to introduce mv / move like behaviour, where
>> the socket can be rebound without races and without interruption?
>
> I believe you can do that today if you write the application such that the
> old instance, before it closes the listen endpoint and terminates, instead
> passes access to it to the new instance via a Unix domain socket between the
> two.

Hi Rick,

That sounds rather complicated. What daemons implement the
functionality this way?
I think an easier way to accomplish this would be quite welcome.

Olaf
