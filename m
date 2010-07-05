From: sbs <gexlie@gmail.com>
Subject: Re: IGB driver upgrade
Date: Mon, 5 Jul 2010 10:45:54 +0400
Message-ID: <AANLkTim37IrxmK9EinvGDwx91D0V1P1Ll3jRhNVy-dtX@mail.gmail.com>
References: <AANLkTim6kfnr6yNeUXlLHOztB-qjyvj50D4p7nebqj9r@mail.gmail.com>
	<AANLkTinUoQG4BWC4Q2UFDwGvAwYujlUXz6P-ZLkZozaQ@mail.gmail.com>
	<4C293792.6070508@intel.com> <AANLkTim4zvNHegMqBnQG5jNGFU8nsaZbx83gv7FZuznu@mail.gmail.com>
	<4C2A1C3C.3040403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43783 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab0GEGq0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 02:46:26 -0400
Received: by bwz1 with SMTP id 1so2508241bwz.19
        for <netdev@vger.kernel.org>; Sun, 04 Jul 2010 23:46:24 -0700 (PDT)
In-Reply-To: <4C2A1C3C.3040403@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have tested 2.0.6 and 2.1.9 modules for 4 days and there were no any
issues detected :)


On Tue, Jun 29, 2010 at 8:15 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> sbs wrote:
>>
>> We're running 2.6.33.2 kernel version.
>> I have compiled and installed 2.0.6 and 2.1.9 modules on two our ser=
vers.
>>
>> Strange freezes usually appears in several (1 or 2) days.
>> So I'll let you know when it happen and what module version will be
>> responsible for that
>
> Since the issue is being seen with the in-kernel driver and not the
> standalone module one other possibility is that this could be an issu=
e that
> is specific to multi-queue. =A0You can test for this by setting the R=
SS
> parameter to 0 for the standalone module to enable multiple queues on=
 the
> 2.2.9 driver.

Thank you, I'll install 2.6.35-rc4 today on several servers with both
standalone(with RSS=3D0) and static driver and let you know after.

>
> One other thing you might want to try would be to test the latest rel=
ease
> candidate kernel from kernel.org. =A0This would help to tell us if th=
is is
> still an issue in the current kernel, or an issue that is present in =
just
> 2.6.33.
>
> Thanks,
>
> Alex
>
