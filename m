From: jamal <hadi@cyberus.ca>
Subject: Re: Oops in IFB
Date: Thu, 20 Jul 2006 09:58:13 -0400
Message-ID: <1153403893.5098.79.camel@jzny2>
References: <44BF8628.9080204@6wind.com>  <1153402801.5098.66.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:3538 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030289AbWGTN6R
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 09:58:17 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G3Z2i-0004Wm-0K
	for netdev@vger.kernel.org; Thu, 20 Jul 2006 09:58:20 -0400
To: nicolas.dichtel@6wind.com
In-Reply-To: <1153402801.5098.66.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-20-07 at 09:40 -0400, jamal wrote:
> On Thu, 2006-20-07 at 15:33 +0200, Nicolas DICHTEL wrote:
> 
> 
> > [IFB] After ifb_init_one() failed, i is increased. Decrease
> > it before entering in the loop for freeing the other ifb devices.
> > 
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Thanks Nicolas.
> 

BTW, in the name of the LinuxWay(tm) - can you also submit a similar
patch for dummy? It suffers from the same bug.

cheers,
jamal

