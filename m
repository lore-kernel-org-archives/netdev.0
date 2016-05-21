From: Tom Herbert <tom@herbertland.com>
Subject: Re: IPv6 extension header privileges
Date: Sat, 21 May 2016 08:19:44 -0700
Message-ID: <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
	<1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
	<20160521015604.GD2452@oracle.com>
	<1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37030 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbcEUPTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 11:19:45 -0400
Received: by mail-ig0-f169.google.com with SMTP id l10so6923384igk.0
        for <netdev@vger.kernel.org>; Sat, 21 May 2016 08:19:44 -0700 (PDT)
In-Reply-To: <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 21, 2016 at 2:34 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Sat, May 21, 2016, at 03:56, Sowmini Varadhan wrote:
>> On (05/21/16 02:20), Hannes Frederic Sowa wrote:
>> >
>> > There are some options inherently protocol depending like the jumbo
>> > payload option, which should be under control of the kernel, or the
>> > router alert option for igmp, which causes packets to be steered towards
>> > the slow/software path of routers, which can be used for DoS attacks.
>> >
>> > Setting CALIPSO options in IPv6 on packets as users would defeat the
>> > whole CALIPSO model, etc.
>> >
>> > The RFC3542 requires at least some of the options in dst/hop-by-hop
>>
>> "requires" is a strong word. 3542 declares it as a  "may" (lower case).
>> The only thing required strongly is IPV6_NEXTHOP itself.
>>
>> I suspect 3542 was written at a time when hbh and dst opt were loosely
>> defined and the "may" is just a place-holder (i.e., it's not even a MAY)
>
> My wording directly from the RFC was too strong, true, but given that
> there is a CALIPSO patch already floating around for the kernel and
> those options are strictly controlled by selinux policy and build the
> foundation for the networking separation we can't make it simply
> non-priv.
>
If you don't mind I'll change this to make specific options are
privileged and not all hbh and destopt. There is talk in IETF about
reinventing IP extensibility within UDP since the kernel APIs don't
allow setting EH. I would like to avoid that :-)

> Bye,
> Hannes
