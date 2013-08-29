From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: packet: use reciprocal_divide in
 fanout_demux_hash
Date: Thu, 29 Aug 2013 01:47:33 +0000 (UTC)
Message-ID: <kvm97k$e8$1@ger.gmane.org>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
 <1377720791-15844-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59511 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752414Ab3H2Bry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 21:47:54 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VErKx-0002FM-Rl
	for netdev@vger.kernel.org; Thu, 29 Aug 2013 03:47:51 +0200
Received: from 36.4.103.164 ([36.4.103.164])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 03:47:51 +0200
Received: from xiyou.wangcong by 36.4.103.164 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 03:47:51 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 at 20:13 GMT, Daniel Borkmann <dborkman@redhat.com> wrote:
> Instead of hard-coding reciprocal_divide function, use the inline
> function from reciprocal_div.h.
>

Then you should #include <linux/reciprocal_div.h> directly?
