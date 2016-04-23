From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 12/12] net/mlx5e: Disable link up on INIT HCA command
Date: Sun, 24 Apr 2016 00:28:39 +0300
Message-ID: <CAJ3xEMh43Z+AoM=TzKZAEFBy=XR2Myy7UQ=k+XJode5mC734WQ@mail.gmail.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
	<1461351647-27412-13-git-send-email-saeedm@mellanox.com>
	<20160423160023.GA15013@colbert.Home>
	<CALzJLG-AWFHnba=ysCAQLqCjFHo3L-sQTeW+NbpMg-X6PRtRPQ@mail.gmail.com>
	<CAJ3xEMg_KFKRvCt5kBZzF_gmkLwg=2dZ=-FCjdbmgkX2-E0s3Q@mail.gmail.com>
	<CALzJLG8Jo5sk=CiHAUDF43RZDGQ1LKRbZftYDpzsO3QJsWx-uA@mail.gmail.com>
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
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38562 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbcDWV2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 17:28:40 -0400
Received: by mail-ig0-f180.google.com with SMTP id m9so38976349ige.1
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 14:28:40 -0700 (PDT)
In-Reply-To: <CALzJLG8Jo5sk=CiHAUDF43RZDGQ1LKRbZftYDpzsO3QJsWx-uA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 24, 2016 at 12:24 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Sat, Apr 23, 2016 at 11:28 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Sat, Apr 23, 2016 at 11:21 PM, Saeed Mahameed
>> <saeedm@dev.mellanox.co.il> wrote:
>>> On Sat, Apr 23, 2016 at 7:00 PM, Ido Schimmel <idosch@mellanox.com> wrote:
>>
>>>> Also, why is this directed at net-next?
>>
>>> it is kind of new behavior, and not a bug fix.
>>
>> Saeed,
>>
>> We should be aiming to patch the driver around this issue with
>> something that goes all the way back through -stable to the very 1st
>> upstream kernel supporting mlx5 EN --- the operational link doesn't go
>> down when instructed by the admin and this is an entry level
>> requirement from Ethernet of things (such as NIC and Switch ports).
>
> Well, this feature requires updating mlx5_ifc, which was done in
> earlier patch which added disable_link_up[0x1] bit,
> I think it is doable, but it will introduce a conflict that Dave might
> need to solve by not taking this bit from the patch I will send to net
> if we decide to do so,
> are you saying that i need to drop this patch and submit it to net ?

net-next is rebased over net and when needed conflicts are solved. Do
the right patch for net and we will take it from there. Please make
sure your patch/es meet the -stable criteria so they can be pushed
there as well.

Or.
