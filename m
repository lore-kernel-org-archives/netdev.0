From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: [Bug 60669] Kernel panic when using negative priority for
 HTB class
Date: Fri, 2 Aug 2013 04:50:16 +0000 (UTC)
Message-ID: <ktfdq8$882$1@ger.gmane.org>
References: <20130801211231.1b25c3be@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40593 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab3HBEuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 00:50:35 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1V57Jy-0005IJ-5c
	for netdev@vger.kernel.org; Fri, 02 Aug 2013 06:50:34 +0200
Received: from 60.160.69.36 ([60.160.69.36])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 06:50:34 +0200
Received: from xiyou.wangcong by 60.160.69.36 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 06:50:34 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 Aug 2013 at 04:12 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
>
> --- Comment #2 from _Vi <vi0oss@gmail.com> ---
> Reproducible on 3.11.0-rc3
>
> Looks like negative priority value is essential for the kernel panic.
>

There is a check for prio:

                if ((cl->prio = hopt->prio) >= TC_HTB_NUMPRIO)
		                        cl->prio = TC_HTB_NUMPRIO - 1;
					
