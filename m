From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V1 08/12] net/mlx5e: Move to checksum complete
Date: Fri, 19 Feb 2016 10:21:24 +0200
Message-ID: <CAJ3xEMibGLtTVYVHqjvHTMUPB3xU6MHnLJ4dhKPPnzq-e==-+Q@mail.gmail.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
	<1455791573-5270-9-git-send-email-saeedm@mellanox.com>
	<CALx6S36MtF+Z44_ti57tJ+RMKNehTLYW18HfAHsvGJpUDXty4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33919 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426497AbcBSIVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 03:21:25 -0500
Received: by mail-io0-f176.google.com with SMTP id 9so101845183iom.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 00:21:25 -0800 (PST)
In-Reply-To: <CALx6S36MtF+Z44_ti57tJ+RMKNehTLYW18HfAHsvGJpUDXty4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 4:25 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Feb 18, 2016 at 2:32 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> From: Matthew Finlay <matt@mellanox.com>

>> Use checksum complete for all IP packets, unless they are HW LRO,
>> in which case, use checksum unnecessary.

> Awesome!

I know...

> Thanks for this fix.

we consider it  a feature ...
