From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [PATCH v3] linux: Report supported user features to
 the kernel
Date: Thu, 19 Dec 2013 10:14:45 -0800
Message-ID: <20131219181445.GG12514@nicira.com>
References: <399ecc79d2539f4624d9b5363f37c8d358571fae.1387466318.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:42179 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754438Ab3LSSOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 13:14:53 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so1470051pbc.5
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 10:14:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <399ecc79d2539f4624d9b5363f37c8d358571fae.1387466318.git.tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 04:20:42PM +0100, Thomas Graf wrote:
> Following commit (''netlink: Do not enforce alignment of last Netlink
> attribute''), signal the ability to receive unaligned Netlink messages
> to the datapath to enable utilization of zerocopy optimizations.
> 
> Opening a datapath is now done by issueing a OVS_DP_CMD_SET in order
> to overwrite previously set user features.
> 
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

Jesse, I'm not sure of the status of this whole effort so I'll just say
that I'm happy with this patch:

Acked-by: Ben Pfaff <blp@nicira.com>
