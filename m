From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] switchdev: add swdev ops
Date: Fri, 20 Mar 2015 16:58:23 -0700
Message-ID: <CAE4R7bA8xndMw4Pdpj1S-CEf3z4hF56Bu1eU8PrEccCZn+BMpQ@mail.gmail.com>
References: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
	<1426470321-48669-2-git-send-email-sfeldma@gmail.com>
	<1426892453.32382.12.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36157 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbCTX6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 19:58:23 -0400
Received: by qgez102 with SMTP id z102so17500976qge.3
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 16:58:23 -0700 (PDT)
In-Reply-To: <1426892453.32382.12.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 4:00 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sun, 2015-03-15 at 18:45 -0700, sfeldma@gmail.com wrote:
> [...]
>> +/**
>> + * struct switchdev_ops - switchdev operations
>> + *
>> + * int (*swdev_parent_id_get)(struct net_device *dev,
>> + *                         struct netdev_phys_item_id *psid);
>> + *   Called to get an ID of the switch chip this port is part of.
>> + *   If driver implements this, it indicates that it represents a port
>> + *   of a switch chip.
>> + *
>> + * int (*swdev_port_stp_update)(struct net_device *dev, u8 state);
>> + *   Called to notify switch device port of bridge port STP
>> + *   state change.
>> + *
>> + * int (*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
>> + *                        int dst_len, struct fib_info *fi,
>> + *                        u8 tos, u8 type, u32 nlflags, u32 tb_id);
>> + *   Called to add/modify IPv4 route to switch device.
>> + *
>> + * int (*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
>> + *                        int dst_len, struct fib_info *fi,
>> + *                        u8 tos, u8 type, u32 tb_id);
>> + *   Called to delete IPv4 route from switch device.
> [...]
>
> This isn't correct kernel-doc syntax.

It was a cut-and-paste from netdevice.h.  Give me an example of
correct syntax, and I'll fix these.

-scott
