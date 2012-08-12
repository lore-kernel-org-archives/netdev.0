From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 16:15:52 +0300
Message-ID: <5027AC88.2020509@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <20120812102240.GG1421@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:53792 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751722Ab2HLNRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 09:17:02 -0400
In-Reply-To: <20120812102240.GG1421@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 13:22, Michael S. Tsirkin wrote:
>>> >>- IGMP/MAC snooping in a driver is just too hairy.
>>
>> >mmm, any rough idea/direction how to do that otherwise?
> Sure, even two ways, ideally you'd do both:)
> A. fix macvtap
> 1. Use netdev_for_each_mc_addr etc to get multicast addresses
> 2. teach macvtap to fill that in (it currently floods multicasts
>     for guest to guest communication so we ned to fix it anyway)
>
> B. fix bridge
>     teach bridge to work for VMs without using promisc mode

I wasn't sure to fully follow... need some more bits of info, the 
macvtap fix
relates only to IGMP snooping, correct? as for the bridge fix, does this 
somehow
relates to ARP snooping we do in the driver? how?

Or.
