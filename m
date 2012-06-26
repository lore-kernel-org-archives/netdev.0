From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC net-next (v2) 12/14] ixgbe: set maximal number of
 default RSS queues
Date: Tue, 26 Jun 2012 21:23:52 +0300
Message-ID: <1340735032.2486.35.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
 <1340624745-8650-13-git-send-email-yuvalmin@broadcom.com>
 <4FE88770.7070007@intel.com>
 <1340646818.2486.27.camel@lb-tlvb-eilong.il.broadcom.com>
 <4FE8B019.4030807@intel.com> <4FE9983C.2060006@broadcom.com>
 <4FE9DB88.5070208@intel.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"John Fastabend" <john.r.fastabend@intel.com>
To: "Alexander Duyck" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1977 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755973Ab2FZSYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 14:24:01 -0400
In-Reply-To: <4FE9DB88.5070208@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 08:55 -0700, Alexander Duyck wrote:
> One thing that just occurred to me though is that this is going to lock
> the upper limit for us and we won't be able to override it if we
> implement the set channels code.  I believe the same thing goes for the
> igb driver as well.
> 
> Is there any chance you could just bypass the ixgbe and igb drivers for
> now and give us time to come up with a more complete solution that would
> allow us to add the set_channels calls.  One issue is I have a number of
> ixgbe patches that are going to be completely rewriting this code anyway
> so I could probably just add set_channels support and support for your
> function once it is included in net-next.

Alex,

I share your concern. I actually brought it up originally when
discussing this RFC:
http://marc.info/?l=linux-netdev&m=133991625809201&w=2

>From my end, if you would like to add the Intel side support that would
be great. Unless anyone object, we will leave the ixgbe and igb out of
this patch series.

Thanks,
Eilon
