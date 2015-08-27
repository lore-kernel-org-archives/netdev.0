From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics
 via debugfs
Date: Thu, 27 Aug 2015 08:27:04 +0200
Message-ID: <20150827062704.GE2228@nanopsycho.orion>
References: <20150826.104906.9246591425074015.davem@davemloft.net>
 <CAE4R7bDZqrgtzi5dAdCgSxy_hTHE9MPfD1WENX3ea7ZXps7+Mw@mail.gmail.com>
 <20150827054004.GA2228@nanopsycho.orion>
 <20150826.230115.2076911912997875741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com, jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34725 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912AbbH0G1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:27:07 -0400
Received: by widdq5 with SMTP id dq5so67216291wid.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 23:27:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150826.230115.2076911912997875741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 27, 2015 at 08:01:15AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu, 27 Aug 2015 07:40:04 +0200
>
>> Switch object itselt would not help you to expose rocker internals. I
>> don't think that you can find generic way, same for all drivers, to
>> expose internal tables and stuff. That is hw specific.
>
>Tables are datastructures with names and types.
>
>Is it not possible to describe datastructures and their types with
>user visible interfaces?

I'm not saying it is not possible, it certainly is. But I think that for
example rocker internals have no value to default user, he should not
care and he cannot find out what is going on there without knowledge or
rocker.c code. The question is, do we need some standard interface to
expose random debugging data? I don't think so, I think that debugfs is
exactly the tool to be used in that case.

>
>Anyone against what I am saying right now is simply lazy.

Not lazy, just thinking :)
