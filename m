From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: Implementing RSTP and MSTP in Linux Kernel
Date: Wed, 9 Jul 2008 09:21:43 -0700
Message-ID: <20080709092143.19b9d9da@speedy>
References: <6dd1343e0807090900s3d905da1qe36cf21731fd3d4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "\"G\"" <balajig81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39999 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbYGIQVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 12:21:44 -0400
In-Reply-To: <6dd1343e0807090900s3d905da1qe36cf21731fd3d4e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jul 2008 21:30:16 +0530
"\"G\"" <balajig81@gmail.com> wrote:

> Hi all
> 
> I am trying to extend the Linux bridging functionaltiy by adding
> support for RSTP and MSTP in the linux kernel and i want to implement
> it as a linux kernel module. I would like to know whats that i ve to
> take care of while implementing this functionlality especially with
> respect to locks etc. I ve gone through the basic bridging code so any
> suggestions on this implementation would be of real good help.
> 
> Thanks for your time
> 
> Cheers,
> Balaji
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

There is already an out of kernel rstpd in user space (actually two of them),
and a couple of people had done RSTP in kernel in older 2.4 embedded devices.
