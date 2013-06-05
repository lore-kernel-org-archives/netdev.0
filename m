From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 01/10] vxlan: only migrate dynamic FDB entries
Date: Wed, 5 Jun 2013 06:23:47 +0000 (UTC)
Message-ID: <komlhj$aca$1@ger.gmane.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43584 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab3FEGYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 02:24:12 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uk78l-0006zU-Iz
	for netdev@vger.kernel.org; Wed, 05 Jun 2013 08:24:11 +0200
Received: from 60.160.70.221 ([60.160.70.221])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 08:24:11 +0200
Received: from xiyou.wangcong by 60.160.70.221 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 08:24:11 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jun 2013 at 04:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> Only migrate dynamic forwarding table entries, don't modify
> static entries. If packet received from incorrect source IP address
> assume it is an imposter and drop it.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>

Nitpick: return bool instead of int
