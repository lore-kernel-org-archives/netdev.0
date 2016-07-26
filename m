From: Tom Herbert <tom@herbertland.com>
Subject: Re: [iovisor-dev] XDP seeking input from NIC hardware vendors
Date: Tue, 26 Jul 2016 09:08:44 -0700
Message-ID: <CALx6S35XjCsG5EmiYBpbGk9NckQbe4VbNSGLqV7h+d16PgNGKg@mail.gmail.com>
References: <20160707124245.6d95635a@redhat.com> <5785413D.4050901@gmail.com>
 <20160712223231.202cd122@redhat.com> <1619174.FzfZHYFiS5@xps13>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert via iovisor-dev <iovisor-dev@lists.iovisor.org>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Edward Cree <ecree@solarflare.com>,
	Simon Horman <simon.horman@netronome.com>,
	Rana Shahout <ranas@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, Ari Saha <as754m@att.com>,
	adrien.mazarguil@6wind.com
To: Thomas Monjalon <thomas.monjalon@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33929 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbcGZQIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:08:46 -0400
Received: by mail-io0-f196.google.com with SMTP id g86so2304995ioj.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:08:45 -0700 (PDT)
In-Reply-To: <1619174.FzfZHYFiS5@xps13>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2016 at 6:31 AM, Thomas Monjalon
<thomas.monjalon@6wind.com> wrote:
> Hi,
>
> About RX filtering, there is an ongoing effort in DPDK to write an API
> which could leverage most of the hardware capabilities of any NICs:
>         https://rawgit.com/6WIND/rte_flow/master/rte_flow.html
>         http://thread.gmane.org/gmane.comp.networking.dpdk.devel/43352
> I understand that XDP does not target to support every hardware features,
> though it may be an interesting approach to check.
>
Thomas,

A major goal of XDP is to leverage and in fact encourage innovation in
hardware features. But, we are asking that vendors design the APIs
with the community in mind. For instance, if XDP supports crypto
offload it should have one API that different companies, we don't want
every vendor coming up with their own.

> 2016-07-12 22:32, Jesper Dangaard Brouer via iovisor-dev:
>> On Tue, 12 Jul 2016 12:13:01 -0700
>> John Fastabend <john.fastabend@gmail.com> wrote:
>> >
>> > Another use case I have is to make a really high performance AF_PACKET
>> > interface. So if there was a way to say bind a queue to an AF_PACKET
>> > ring and run a policy XDP program before hitting the AF_PACKET
>> > descriptor bit that would be really interesting because it would solve
>> > some of my need for poll mode drivers in userspace.
>
> Have you started this work?
> Do you have an idea of how RX would perform through XDP + AF_PACKET + DPDK?
>
I don't understand why the AF_PACKET with DPDK. They should be
mutually exclusive. XDP over DPDK does make sense.

Tom
