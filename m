From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH/RFC] make unregister_netdev() delete more than 4 interfaces per second
Date: Wed, 21 Oct 2009 15:39:01 +0300
Message-ID: <200910211539.01824.opurdila@ixiacom.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:17342 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751479AbZJUMlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 08:41:51 -0400
In-Reply-To: <20091018182144.GC23395@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 18 October 2009 21:21:44 you wrote:
> > The msleep(250) should be tuned first. Then if this is really necessary
> > to dismantle 100.000 netdevices per second, we might have to think a bit
> > more. 
> > Just try msleep(1 or 2), it should work quite well.
> 
> My goal is tearing down 100,000 interfaces in a few seconds, which really
>  is  necessary.  Right now we're running about 40,000 interfaces on a not
>  yet saturated 10Gbps link.  Going to dual 10Gbps links means pushing more
>  than 100,000 subscriber interfaces, and it looks like a modern dual socket
>  system can handle that.
> 

I would also like to see this patch in, we are running into scalability issues 
with creating/deleting lots of interfaces as well.

Thanks,
tavi
