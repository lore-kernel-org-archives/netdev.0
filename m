From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 12/12] net/mlx5e: Disable link up on INIT HCA command
Date: Sat, 23 Apr 2016 23:28:11 +0300
Message-ID: <CAJ3xEMg_KFKRvCt5kBZzF_gmkLwg=2dZ=-FCjdbmgkX2-E0s3Q@mail.gmail.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
	<1461351647-27412-13-git-send-email-saeedm@mellanox.com>
	<20160423160023.GA15013@colbert.Home>
	<CALzJLG-AWFHnba=ysCAQLqCjFHo3L-sQTeW+NbpMg-X6PRtRPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ido Schimmel <idosch@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33878 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbcDWU2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 16:28:12 -0400
Received: by mail-io0-f182.google.com with SMTP id 2so150394141ioy.1
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 13:28:12 -0700 (PDT)
In-Reply-To: <CALzJLG-AWFHnba=ysCAQLqCjFHo3L-sQTeW+NbpMg-X6PRtRPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 23, 2016 at 11:21 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Sat, Apr 23, 2016 at 7:00 PM, Ido Schimmel <idosch@mellanox.com> wrote:

>> Also, why is this directed at net-next?

> it is kind of new behavior, and not a bug fix.

Saeed,

We should be aiming to patch the driver around this issue with
something that goes all the way back through -stable to the very 1st
upstream kernel supporting mlx5 EN --- the operational link doesn't go
down when instructed by the admin and this is an entry level
requirement from Ethernet of things (such as NIC and Switch ports).
