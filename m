From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add user-space support
 for extended attributes
Date: Wed, 2 Mar 2016 09:23:03 -0800
Message-ID: <20160302092303.338348a7@xeon-e3>
References: <1456149621-27335-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35473 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbcCBRWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 12:22:51 -0500
Received: by mail-pa0-f45.google.com with SMTP id bj10so67299049pad.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 09:22:51 -0800 (PST)
In-Reply-To: <1456149621-27335-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Feb 2016 15:00:21 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Recently support was added to the kernel to be able to add more per-mdb
> entry attributes via standard netlink attributes of type MDBA_MDB_EATTR_.
> This patch adds support to iproute2 to parse and output these
> attributes. The first exported attribute is the mdb "timer" value which
> is shown only when the "-d" iproute2 arg is used.
> 
> Example:
> $ bridge -d mdb show
> dev br0 port eth1 grp 239.0.0.11 permanent   0.00
> dev br0 port eth2 grp 239.0.0.11 permanent   0.00
> dev br0 port eth1 grp 239.0.0.10 temp 244.38
> dev br0 port eth1 grp 239.0.0.1 temp 245.41
> dev br0 port eth1 grp 239.0.0.5 temp 246.43
> dev br0 port eth2 grp 239.0.0.5 temp 248.48
> dev br0 port eth1 grp 239.0.0.2 temp 245.41
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
