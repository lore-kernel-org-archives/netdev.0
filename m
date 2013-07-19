From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH iproute2 v5] vxlan: Allow setting destination to unicast
 address.
Date: Fri, 19 Jul 2013 08:12:40 +0000 (UTC)
Message-ID: <ksasdn$m3m$1@ger.gmane.org>
References: <877ggpy15n.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:41618 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755080Ab3GSINB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jul 2013 04:13:01 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1V05oA-0002sj-2M
	for netdev@vger.kernel.org; Fri, 19 Jul 2013 10:12:58 +0200
Received: from 116.53.101.133 ([116.53.101.133])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 10:12:58 +0200
Received: from xiyou.wangcong by 116.53.101.133 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 10:12:58 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Jul 2013 at 09:40 GMT, Atzm Watanabe <atzm@stratosphere.co.jp> wrote:
> This patch allows setting VXLAN destination to unicast address.
> It allows that VXLAN can be used as peer-to-peer tunnel without
> multicast.
>
...
>  {
> -	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ local ADDR ]\n");
> +	fprintf(stderr, "Usage: ... vxlan id VNI [ remote ADDR ] [ local ADDR ]\n");

This clearly breaks existing scripts, you should keep 'group' and just add
'remote'.
