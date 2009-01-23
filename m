From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: net-next-2.6 is live
Date: Thu, 22 Jan 2009 19:17:26 -0800
Message-ID: <9929d2390901221917s606489c3wfe77612c9c989433@mail.gmail.com>
References: <20090121.165820.171747430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.185]:50437 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754943AbZAWDR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 22:17:28 -0500
In-Reply-To: <20090121.165820.171747430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 4:58 PM, David Miller <davem@davemloft.net> wrote:
>
> Ok, I've pushed all of the patches I've applied for 2.6.30 off to:
>
>        master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>
> Enjoy.
> --

Dave, the net-next tree seems to be missing this patch...


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jan 2009 16:17:08 -0800

e1000e: drop lltx, remove unnecessary lock

 LLTX is deprecated and complicated, don't use it.  It was observed by Don Ash
 <donash4@gmail.com> that e1000e was acquiring this lock in the NAPI cleanup
 path.  This is obviously a bug, as this is a leftover from when e1000
 supported multiple tx queues and fake netdevs.

 another user reported this to us and tested routing with the 2.6.27 kernel and
 this patch and reported a 3.5 % improvement in packets forwarded in a
 multi-port test on 82571 parts.

 Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
 Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
 Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
