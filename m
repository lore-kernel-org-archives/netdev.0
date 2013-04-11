From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 18:30:19 +0800
Message-ID: <CACVXFVO+QZ+mtdOFuNuh+8HQOMcuQrKJRAaW9ohyrMCMeZXsjQ@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site>
	<87txndwkx1.fsf@nemi.mork.no>
	<CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
	<87ppy1wfhq.fsf@nemi.mork.no>
	<CACVXFVNn9MQr6JLdin=u642Jb-2ZPfVk8YaBmNdhU0_2e7WJqQ@mail.gmail.com>
	<87hajdwefp.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:64070 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab3DKKaU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 06:30:20 -0400
In-Reply-To: <87hajdwefp.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 6:26 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <tom.leiming@gmail.com> writes:
>
>> On Thu, Apr 11, 2013 at 6:04 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>>> Ming Lei <tom.leiming@gmail.com> writes:
>>>
>>> Again: What problem are you attempting to solve by removing the
>>> mem_flags from the API?
>>
>> It is not about removing anything, we are discussing one new API
>> (include the parameters) to be introduced.
>
> Yes.  Sure.  And the original proposal was to add a new API with a
> mem_flags parameter.  You proposed to add the same API, but without t=
he
> mem_flags parameter.  You did not explain why.  I still assumed that =
you
> have some reason to propose it.  I assumed that reason must be some
> problem which would be introduced by having the mem_flags parameter, =
and
> which would be solved if we instead drop it.
>
> It seems that you are either unable or unwilling to explain your
> reasons, so I'll just go ahead and drop my assumptions.  You never ha=
d
> any reason and there never would be any problem.

OK, I say it again, GFP_KERNEL is enough to cover all cases, and the
mem_flags parameter is redundant.


Thanks,
--=20
Ming Lei
