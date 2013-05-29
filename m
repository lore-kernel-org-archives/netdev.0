From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default
 destinations
Date: Wed, 29 May 2013 10:13:48 +0000 (UTC)
Message-ID: <ko4kcr$h8j$1@ger.gmane.org>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38562 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965275Ab3E2KOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 06:14:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UhdOO-0003nE-5m
	for netdev@vger.kernel.org; Wed, 29 May 2013 12:14:04 +0200
Received: from 180.183.217.220 ([180.183.217.220])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 12:14:04 +0200
Received: from xiyou.wangcong by 180.183.217.220 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 12:14:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 May 2013 at 10:00 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ---
>  ip/iplink_vxlan.c | 125 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 125 insertions(+)
>
> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> index 1025326..be6c0ac 100644
> --- a/ip/iplink_vxlan.c
> +++ b/ip/iplink_vxlan.c
> @@ -28,11 +28,87 @@ static void explain(void)
>  	fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
>  	fprintf(stderr, "                 [ [no]proxy ] [ [no]rsc ]\n");
>  	fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
> +	fprintf(stderr, "                 [ dstadd DST ]\n");
> +	fprintf(stderr, "                 [ dstdel ADDR ]\n");

Excuse me, but this looks like a design failure as you manipulate
remotes with `ip link` while creating vxlan devices, shouldn't this be
in a standard alone tool if we can't reuse any existing tool? Or am I
missing anything?
