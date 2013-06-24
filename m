From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH iproute2 2/2] vxlan: allow specifying multiple default
 destinations
Date: Mon, 24 Jun 2013 00:32:49 +0000 (UTC)
Message-ID: <kq843h$n38$1@ger.gmane.org>
References: <1372004643-24718-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1372004643-24718-2-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:51627 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab3FXAdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jun 2013 20:33:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UquiQ-0004d5-6B
	for netdev@vger.kernel.org; Mon, 24 Jun 2013 02:33:06 +0200
Received: from 218.63.189.90 ([218.63.189.90])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 02:33:06 +0200
Received: from xiyou.wangcong by 218.63.189.90 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 02:33:06 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jun 2013 at 16:24 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> +static void explain_change(void)
> +{
> +	fprintf(stderr, "Usage: ... vxlan id VNI\n");
> +	fprintf(stderr, "                 [ dstadd DST ]\n");
> +	fprintf(stderr, "                 [ dstdel ADDR ]\n");
> +	fprintf(stderr, "\n");
> +	fprintf(stderr, "Where: VNI := 0-16777215\n");
> ++	fprintf(stderr, "       DST  := [ ADDR [port PORT] [vni VNI] [via DEV]]\n");

This '++' line does't look correct, does it?
