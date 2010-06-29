From: sbs <gexlie@gmail.com>
Subject: Re: IGB driver upgrade
Date: Tue, 29 Jun 2010 13:50:18 +0400
Message-ID: <AANLkTim4zvNHegMqBnQG5jNGFU8nsaZbx83gv7FZuznu@mail.gmail.com>
References: <AANLkTim6kfnr6yNeUXlLHOztB-qjyvj50D4p7nebqj9r@mail.gmail.com>
	<AANLkTinUoQG4BWC4Q2UFDwGvAwYujlUXz6P-ZLkZozaQ@mail.gmail.com>
	<4C293792.6070508@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50156 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab0F2JuU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 05:50:20 -0400
Received: by bwz1 with SMTP id 1so614617bwz.19
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 02:50:19 -0700 (PDT)
In-Reply-To: <4C293792.6070508@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 29, 2010 at 4:00 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> sbs wrote:
>>
>> Hello guys.
>>
>> Is it possible to upgrade intel gigabit adapter's e1000 driver to
>> 2.2.9? This is the latest version according to Intel website.
>>
> I assume you are referring to the igb driver since that is what is in=
 the
> subject and not the e1000 driver correct?


Yes , sorry i mean IGB of course.



>
>> I've got a problem with 2.1.0-k2 drivers statically compiled into ke=
rnel.
>>
>> Surely I can download drivers from intel and compile it as module, b=
ut
>> I need to compile it statically
>> Intel drivers do not provide sources for static compilation :(
>>
>> Is it possible to upgrade drivers to igb-2.2.9 in the source tree an=
d
>> allow the static compilation of them?
>>
> Normally the upstream driver should be up to date with any fixes that=
 are in
> the standalone module. =A0What version of the kernel are you currentl=
y
> running? =A0Also have your tried testing the older standalone igb mod=
ules to
> see if the same issues exist there in either igb 2.1.9 or =A0igb 2.0.=
6? =A0This
> would help us to determine what changes in the standalone module migh=
t be
> missing from the in-kernel version of the driver.



We're running 2.6.33.2 kernel version.
I have compiled and installed 2.0.6 and 2.1.9 modules on two our server=
s.

Strange freezes usually appears in several (1 or 2) days.
So I'll let you know when it happen and what module version will be
responsible for that


>
>> Because having 2.1.0-k2 we experience some strange random freezes wi=
th
>> network interface which can be fixed only by restarting network.
>>
>> 2.2.9 module has no such problems but we need to use static kernels
>> according to our policy.
>
> I have CCed our e1000-devel list. =A0In the future you may want to CC=
 this
> list as it will provide better visibility to the Intel wired networki=
ng
> maintainers.
>


Thank you for that.


> Thanks,
>
> Alex
>
