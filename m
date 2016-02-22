From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 6/9] mlxsw: spectrum: Unmap local port from module
 during teardown
Date: Mon, 22 Feb 2016 12:32:47 -0800
Message-ID: <56CB706F.3000301@gmail.com>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us> <1456165924-14399-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35530 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbcBVUdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:33:09 -0500
Received: by mail-pa0-f43.google.com with SMTP id ho8so99227712pac.2
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 12:33:08 -0800 (PST)
In-Reply-To: <1456165924-14399-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-22 10:32 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> When splitting a port we replace it with 2 or 4 other ports. To be able
> to do that we need to remove the original port netdev and unmap it from
> its module. However, we first mark it as disabled, as active ports
> cannot be unmapped.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---

Hi Jiri, Ido,

You've sort of lost me on this port splitting/unsplitting thread. What
does this actually do? Are you just creating two netdevs and LAGing them
in the hardware, I'm guessing not or you wouldn't have some device API
for it and would do it using normal methods.

If its something to do with physical layout of the board itself why
don't you trigger this based on some init time introspection or an
interrupt if someone plugs in a port splitting cable/module (does that
exist?).

Thanks,
John
