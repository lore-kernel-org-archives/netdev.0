From: David Shwatrz <dshwatrz@gmail.com>
Subject: Re: Move an interface to init_ne
Date: Wed, 28 Nov 2012 17:31:15 +0200
Message-ID: <CAJJAcofHM+D8_2u-w5jPJZKfeA0A7QOxX1gxTQ2vOgx-L9aZhQ@mail.gmail.com>
References: <CAJJAcodehJ3x2ZjOuoaV=KrWHH23013b3O20nqh0E1smFvFpHw@mail.gmail.com>
	<CAChaegnKhq50mS+T7XrP9A1hYZbT7c+WGD=tUpWtUY2c-ngb7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Renato Westphal <renatowestphal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:62136 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183Ab2K1PbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 10:31:16 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so13522261oag.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 07:31:15 -0800 (PST)
In-Reply-To: <CAChaegnKhq50mS+T7XrP9A1hYZbT7c+WGD=tUpWtUY2c-ngb7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renato,

Thanks a lot!

I have an additional question if I may on network namespaces.

I have a machine with two different nics, with two different drivers,
r8169 and 8139too (both RealTek nics).
I have eth0 on the  initial network namespace and
no interface on namespace1. (8139too module is not loaded).

But when I run "modprobe 8139too" on namespace1, a device named "eth1"
is created on the initial network namespace and not on namesapce1.
I expected that in such a case, a device named "eth0" will be created
on namespace1, since it was called from namespace1. Or maybe modprobe
does
not consider the namespace from which it was called ?

regards,
DS

On Wed, Nov 28, 2012 at 5:01 PM, Renato Westphal
<renatowestphal@gmail.com> wrote:
> initial network namespace
