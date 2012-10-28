From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net-next] pktgen: clean up ktime_t helpers
Date: Sun, 28 Oct 2012 14:31:31 +0000 (UTC)
Message-ID: <k6jfk3$b2j$1@ger.gmane.org>
References: <20121026114250.GA13378@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:55264 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871Ab2J1Obq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2012 10:31:46 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TSTu2-00015b-4g
	for netdev@vger.kernel.org; Sun, 28 Oct 2012 15:31:50 +0100
Received: from 112.132.138.96 ([112.132.138.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 15:31:50 +0100
Received: from xiyou.wangcong by 112.132.138.96 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 15:31:50 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Oct 2012 at 11:42 GMT, Daniel Borkmann <dxchgb@gmail.com> wrote:
> Some years ago, the ktime_t helper functions ktime_now() and ktime_lt()
> have been introduced. Instead of defining them inside pktgen.c, they
> should either use ktime_t library functions or, if not available, they
> should be defined in ktime.h, so that also others can benefit from them.
> ktime_compare() is introduced with a similar notion as in timespec_compare().
>
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>


Looks good. This is a cleanup patch, doesn't need to be RFC, I think.

Thanks.
