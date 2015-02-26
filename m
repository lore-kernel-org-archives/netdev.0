From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/3] rocker: fix non-portable err return codes
Date: Thu, 26 Feb 2015 06:04:51 -0800
Message-ID: <CAE4R7bAvYkfKWzoDy89uvRebWPgwZE6zYgPt8+tvoJ3jE6CsUA@mail.gmail.com>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
	<1424924138-15928-2-git-send-email-sfeldma@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAEE973@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:65298 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932243AbbBZOEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:04:52 -0500
Received: by mail-qg0-f52.google.com with SMTP id h3so8570548qgf.11
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:04:51 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAEE973@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 4:17 AM, David Laight <David.Laight@aculab.com> wrote:
> From: sfeldma@gmail.com
>> The rocker device returns error codes if something goes wrong with descriptor
>> processing.  Originally the device used standard errno codes for different
>> errors, but since those errno codes aren't portable across ARCHs, the device
>> now returns hard-coded error codes that stay constant across diff ARCHs.  Fix
>> driver to use those same hard-coded values.
>
> You might as well use dense error numbers and then an array for the conversion.
> If you want to avoid confusion, then offset the error numbers from zero.

Agreed, but I was stuck by the legacy of older devices which used the
original errno values.  My bad not thinking about errno's being
non-portable.

-scott
