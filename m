From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/16] net: introduce upper device lists
Date: Tue, 14 Aug 2012 12:18:52 +0200
Message-ID: <20120814101852.GA1661@minipsycho.brq.redhat.com>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
 <1344871635-1052-2-git-send-email-jiri@resnulli.us>
 <502A1429.9060005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	faisal.latif@intel.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	linux390@de.ibm.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, therbert@google.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <502A1429.9060005@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Aug 14, 2012 at 11:02:33AM CEST, xiyou.wangcong@gmail.com wrote:
>On 08/13/2012 11:27 PM, Jiri Pirko wrote:
>>This lists are supposed to serve for storing pointers to all upper devices.
>>Eventually it will replace dev->master pointer which is used for
>>bonding, bridge, team but it cannot be used for vlan, macvlan where
>>there might be multiple "masters" present.
>>
>>New upper device list resolves this limitation. Also, the information
>>stored in lists is used for preventing looping setups like
>>"bond->somethingelse->samebond"
>
>Hi, Jiri,
>
>I have some difficulty to understand this patch description, so take
>bridged bonding as an example, IIUC, both the bridge dev and bonding
>dev will be in the upper dev list of eth0 and eth1? And br0 will be
>in the upper dev list of bond0 too?

No. Only direct upper device is in the list.

>
>I think it would be nice to describe the hierarchy after your patches.

Hierarchy is the same after.

>
>Thanks!
>
