From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] qlcnic - Fix scheduling while atomic bug
Date: Fri, 28 Sep 2012 13:08:51 +0530
Message-ID: <E31FB011129F30488D5861F38390491520D4F86604@BLRX7MCDC201.AMER.DELL.COM>
References: <20120925175212.GA1324@fedora-17-guest.blr.amer.dell.com>
 <20120927.192602.1354851114513597606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<jitendra.kalsaria@qlogic.com>, <john.r.fastabend@intel.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:17143 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180Ab2I1HjS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 03:39:18 -0400
In-Reply-To: <20120927.192602.1354851114513597606.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: Friday, September 28, 2012 4:56 AM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; sony.chacko@qlogic.com;
> jitendra.kalsaria@qlogic.com; john.r.fastabend@intel.com
> Subject: Re: [PATCH] qlcnic - Fix scheduling while atomic bug
> 
> From: <Narendra_K@Dell.com>
> Date: Tue, 25 Sep 2012 10:53:19 -0700
> 
> > From: Narendra K <narendra_k@dell.com>
> >
> > In the device close path, 'qlcnic_fw_destroy_ctx' and
> > 'qlcnic_poll_rsp' call msleep. But  'qlcnic_fw_destroy_ctx' and
> > 'qlcnic_poll_rsp' are called with 'adapter->tx_clean_lock' spin lock
> > held resulting in scheduling while atomic bug causing the following
> > trace.
> >
> > I observed that the commit 012dc19a45b2b9cc2ebd14aaa401cf782c2abba4
> > from John Fastabend addresses a similar issue in ixgbevf driver.
> > Adopting the same approach used in the commit, this patch uses mdelay
> > to address the issue.
>  ...
> > Signed-off-by: Narendra K <narendra_k@dell.com>
> 
> Applied, thanks.
> 
> In the future please format your Subject lines for patches as
> "subsytem: Description."  instead of this "subsystem - Description."
> layout.

Hi David, thank you for reviewing and applying the patch. I will follow the suggested layout for future submissions.

Hi Jitendra, thank you for reviewing the patch.
 
With regards,
Narendra K
