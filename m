From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 14 Aug 2012 10:41:27 +0300
Message-ID: <502A0127.2080107@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <20120812102240.GG1421@redhat.com> <5027AC88.2020509@mellanox.com> <20120812135544.GB6003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:46850 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754803Ab2HNHlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 03:41:47 -0400
In-Reply-To: <20120812135544.GB6003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 13:22, Michael S. Tsirkin wrote:
>>>>>>> - IGMP/MAC snooping in a driver is just too hairy.
>>>>
>>>>> mmm, any rough idea/direction how to do that otherwise?
>>> Sure, even two ways, ideally you'd do both:)
>>> A. fix macvtap
>>> 1. Use netdev_for_each_mc_addr etc to get multicast addresses
>>> 2. teach macvtap to fill that in (it currently floods multicasts
>>>     for guest to guest communication so we ned to fix it anyway)
>>>
>>> B. fix bridge
>>>     teach bridge to work for VMs without using promisc mode
>>

OK, I think I'm with you now... you suggest to avoid our direction of 
implementing promiscuous multicast mode which is applied by today's 
bridge, macvtap and friends by fixing these elements to support non 
promisc multicast mode, yep, sure, sounds as win/win, which will 
eliminate the need to do IGMP snooping in the driver.

Or.
