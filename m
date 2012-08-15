From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 01/15] net: introduce upper device
	lists
Date: Wed, 15 Aug 2012 15:12:23 -0700 (PDT)
Message-ID: <20120815.151223.1108632083114612511.davem@davemloft.net>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
	<1344956748-2099-2-git-send-email-jiri@resnulli.us>
	<1344983624.2690.77.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, ursula.braun@de.ibm.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	shemminger@vyatta.com, sean.hefty@intel.com, therbert@google.com,
	roland@kernel.org, linux-s390@vger.kernel.org,
	linux-rdma@vger.kernel.org, fubar@us.ibm.com, fbl@redhat.com,
	hal.rosenstock@gmail.com, jiri@resnulli.us,
	faisal.latif@intel.com, linux-driver@qlogic.com,
	blaschka@linux.vnet.ibm.com, sony.chacko@qlogic.com,
	gregory.v.rose@intel.com, xiyou.wangcong@gmail.com,
	jitendra.kalsaria@qlogic.com, divy@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, linux390@de.ibm.com, kaber@trash.net
To: bhutchings@solarflare.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1344983624.2690.77.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 14 Aug 2012 23:33:44 +0100

> I think we will also need to limit the depth of the device stack so we
> don't run out of stack space here.  __netif_receive() implements a kind
> of tail recursion whenever a packet is passed up, but
> __netdev_has_upper_dev() can't avoid doing real recursion (without the
> addition of a flag to net_device so it can mark its progress).

Agreed, we need some kind of limit here.
