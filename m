From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
	mapping
Date: Fri, 16 Jul 2010 15:29:06 -0400
Message-ID: <AANLkTin3V7LtmhDAOktNF1UITM86sJwButxCQ3vo31lv@mail.gmail.com>
References: <AANLkTinxLy2noL0GcZyVtMsEndxseCr6kkxuvyBNIfHr@mail.gmail.com>
	<1279300205.2097.9.camel@achroite.uk.solarflarecom.com>
	<20100716110407.316eb8f1@s6510>
	<D3F292ADF945FB49B35E96C94C2061B90C55C202@nsmail.netscout.com>
	<20100716113113.1e2b51c7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59046 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966100Ab0GPT3I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 15:29:08 -0400
Received: by vws5 with SMTP id 5so2906043vws.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 12:29:07 -0700 (PDT)
In-Reply-To: <20100716113113.1e2b51c7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 16, 2010 at 2:31 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 16 Jul 2010 14:12:24 -0400
> "Loke, Chetan" <Chetan.Loke@netscout.com> wrote:
>
>> > -----Original Message-----
>> > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>> > Sent: July 16, 2010 2:04 PM
>>
>> > The additional API is not needed. It is trivial to find address fo=
r
>> > device and do reverse mapping. Either with ioctl's
>> Sorry, I might have missed it. But which ioctl would that be?
>
> Simple way:
> =C2=A0 Use SIOCGIFCONF to get list of interfaces
> =C2=A0 Use SIOCGIFHWADDR to read device addresss
>
And interfaces that don't have IP's?
