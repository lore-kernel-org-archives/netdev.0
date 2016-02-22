From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add user-space support for
 extended attributes
Date: Mon, 22 Feb 2016 15:09:06 +0100
Message-ID: <56CB1682.2010006@cumulusnetworks.com>
References: <1456149621-27335-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37882 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973AbcBVOJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 09:09:10 -0500
Received: by mail-wm0-f53.google.com with SMTP id g62so165367750wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 06:09:10 -0800 (PST)
In-Reply-To: <1456149621-27335-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2016 03:00 PM, Nikolay Aleksandrov wrote:
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
> ---
> note: this patch needs updated linux/if_bridge.h header to compile
> 

Self-NAK. I'll use the "-s"/stats as that seems to be used for some time
values instead and will update the man page. v2 coming up.

Sorry about the noise,
 Nik
