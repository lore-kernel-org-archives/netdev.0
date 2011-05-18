From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V4 PATCH] rtnetlink: Compute and store minimum ifinfo dump
 size
Date: Wed, 18 May 2011 15:49:25 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755018E321C4C@orsmsx508.amr.corp.intel.com>
References: <20110518155410.28491.62723.stgit@gitlad.jf.intel.com>
	<20110518.180913.273729651812642114.davem@davemloft.net>
	<43F901BD926A4E43B106BF17856F0755018E321C21@orsmsx508.amr.corp.intel.com>
 <20110518.184741.476096648010572360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41312 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754373Ab1ERWt1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:49:27 -0400
In-Reply-To: <20110518.184741.476096648010572360.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, May 18, 2011 3:48 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> eric.dumazet@gmail.com
> Subject: Re: [RFC V4 PATCH] rtnetlink: Compute and store minimum ifinfo
> dump size
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Wed, 18 May 2011 15:35:58 -0700
> 
> > It looked to me like rtmsg_ifinfo is called when each device is
> > registered through register_netdevice() and rtmsg_ifinfo in turn
> > calls the if_nlmsg_size function returning the ifinfo dump size for
> > each device.  In my testing it looked like the proper maximum size
> > was being set after I loaded the drivers for the SR-IOV capable
> > devices.
> 
> Aha, indeed you're right.  I missed this part.  Thanks for explaining.
> 
> So as far as I can tell it should work, I'll let others review it to
> see if they are ok with this approach.

Ok, sure.  We'll see if Eric catches anything, he's got an eagle eye.

;^)

- Greg

