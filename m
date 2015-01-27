From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 06/10] net/mlx4_core: Fix struct mlx4_vhcr_cmd
 to make implicit padding explicit
Date: Tue, 27 Jan 2015 16:43:02 +0200
Message-ID: <20150127164302.2b2cc3e0@jpm-OptiPlex-GX620>
References: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
	<1422351179-27284-7-git-send-email-amirv@mellanox.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3B01@AcuExch.aculab.com>
	<20150127150027.184ba5e8@jpm-OptiPlex-GX620>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3D71@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55525 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbbA0OmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 09:42:02 -0500
Received: by mail-wi0-f172.google.com with SMTP id h11so5267043wiw.5
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 06:42:01 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3D71@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2015 13:38:28 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> Haven't you broken communication between an old and new
> 32bit Guests and 32bit hosts (assuming they exist)?

Yes, but I don't see any interest on the net in running 32-bit Hosts
with virtualization and SR IOV.  I do see that there is interest in
running 32-bit Guests over 64-bit Hosts (which configuration KVM
supports).

Since this change is *required* for supporting 32-bit Guests on 64-bit
Hosts, I don't see that we have much choice here.

As you say, an old 32-bit Host will not be compatible with a new 32-bit
guest, and vice-versa. However, I would assume that almost all Hosts
would have 64-bit architectures, because of the performance and
memory-space requirements for running SRIOV and virtualization.
Therefore, I don't see this as a stopper.

-Jack
