From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: A generic kernel compatibilty code
Date: Mon, 23 Nov 2009 08:20:08 -0800
Message-ID: <43e72e890911230820x2c784c57he387ffd53a9ccc9@mail.gmail.com>
References: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
	<1258750858.2877.58.camel@achroite.uk.solarflarecom.com> <43e72e890911201307g2a1f280aie223ed4fd270aad@mail.gmail.com>
	<1258982793.2845.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:45965 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869AbZKWQUW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 11:20:22 -0500
In-Reply-To: <1258982793.2845.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2009 at 5:26 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2009-11-20 at 13:07 -0800, Luis R. Rodriguez wrote:
>> On Fri, Nov 20, 2009 at 1:00 PM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> > On Fri, 2009-11-20 at 12:45 -0800, Luis R. Rodriguez wrote:
>> >> Everyone and their mother reinvents the wheel when it comes to
>> >> backporting kernel modules. It a painful job and it seems to me a=
n
>> >> alternative is possible. If we can write generic compatibilty cod=
e for
>> >> a new routine introduced on the next kernel how about just mergin=
g it
>> >> to the kernel under some generic compat module. This would be
>> >> completey ignored by everyone using the stable kernel but can be
>> >> copied by anyone doing backport work.
>> >>
>> >> So I'm thinking something as simple as a generic compat/comat.ko =
with
>> >> compat-2.6.32.[ch] files.
>> >>
>> >> We've already backported everything needed for wireless drivers u=
nder
>> >> compat-wireless under this format down to even 2.6.25.
>> > [...]
>> >
>> > If you think 2.6.25 is old then I don't think you understand the s=
cale
>> > of the problem.
>> >
>> > OEMs still expect us to support RHEL 4 (2.6.9) and SLES 9 (2.6.5) =
though
>> > the latter will probably be dropped soon. =C2=A0Some other vendors=
 apparently
>> > still need to support even 2.4 kernels!
>>
>> Heh understood. Well shouldn't this help with that then? Sure I'd lo=
ve
>> to see the Enteprise Linux releases on 2.6.31 but that's not going t=
o
>> happen right? Shouldn't this help then?
>
> You'd really have to ask the 'enterprise' vendors whether they'd be
> interested in working on some sort of shared forward-compat library.

OK will do thanks.

>=C2=A0If the library is to include a module rather than being statical=
ly linked
> into each module that needs it then there can only be one instance in
> the system.

Sure, that's the idea.

  Luis
