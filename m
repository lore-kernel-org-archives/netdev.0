From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next V4 00/15] net: introduce upper device lists and
 remove dev->master
Date: Wed, 2 Jan 2013 13:30:46 +0100
Message-ID: <20130102123046.GA1532@minipsycho.orion>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
 <20130102.025420.1993175980232815756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:39258 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758Ab3ABMau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 07:30:50 -0500
Received: by mail-ea0-f172.google.com with SMTP id a1so5914688eaa.3
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 04:30:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130102.025420.1993175980232815756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 02, 2013 at 11:54:20AM CET, davem@davemloft.net wrote:
>
>This patch set breaks the build:
>
>drivers/infiniband/hw/nes/nes_cm.c: In function =E2=80=98nes_addr_reso=
lve_neigh=E2=80=99:
>drivers/infiniband/hw/nes/nes_cm.c:1343:3: error: implicit declaration=
 of function =E2=80=98netdev_unique_upper_dev_get=E2=80=99
>
>I could give you a hard time and say that any time you touch a core
>header file you must do something at least approximating an
>allmodconfig build.
>
>But in this case, it is clear that you didn't even test the final
>patch set with this specific infiniband driver enabled.
>
>That's really disappointing.

That option somehow left my config. Sorry about that.
