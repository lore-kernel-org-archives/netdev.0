From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH iproute2 v2] bridge/link: add learning_sync policy flag
Date: Fri, 2 Jan 2015 09:57:18 -0800
Message-ID: <CAE4R7bBpmR429F--8NNx0Jqos_bR-x2G4ybjmPhDW6Q+kV5y2g@mail.gmail.com>
References: <1419884407-21998-1-git-send-email-sfeldma@gmail.com>
	<CA+CtxLS7x8zKQ-9xwjoH3=pidkXS9s5b2+K_VO4eDHJTWo5tYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:56919 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbbABR5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 12:57:20 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so28073799wiw.16
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 09:57:18 -0800 (PST)
In-Reply-To: <CA+CtxLS7x8zKQ-9xwjoH3=pidkXS9s5b2+K_VO4eDHJTWo5tYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 2, 2015 at 9:14 AM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
> Hi,
>
>
>> +.BR "learning_sync on " or " learning_sync off "
>> +Controls whether a given port will sync MAC addresses learned on device port to
>> +bridge FDB.
>> +
>
> For the FDB entries synced from device port to bridge FDB, can the
> device port also mention that it will take care of aging the synced
> entries? I am thinking of a use case where the port supports hardware
> learning and hardware aging?

I think the aging settings are per-bridge, not per-bridge-port, so the
policy control you're talking about wouldn't end up here on
/sbin/bridge link.

However, I would argue even with hardware aging capability, we still
should use Linux for aging since all the controls are already there
and it just works.  It keeps the swdev model simple and the swdev
driver simple.  Do you have a counter-argument for why enabling
hardware aging would be better?

-scott
