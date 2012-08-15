From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 01/15] net: introduce upper device
	lists
Date: Wed, 15 Aug 2012 15:15:49 -0700 (PDT)
Message-ID: <20120815.151549.1835466517645273818.davem@davemloft.net>
References: <1344956748-2099-2-git-send-email-jiri@resnulli.us>
	<1344983624.2690.77.camel@bwh-desktop.uk.solarflarecom.com>
	<20120815074612.GB1726@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, ursula.braun@de.ibm.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	shemminger@vyatta.com, sean.hefty@intel.com, therbert@google.com,
	roland@kernel.org, linux-s390@vger.kernel.org,
	linux-rdma@vger.kernel.org, fubar@us.ibm.com, fbl@redhat.com,
	hal.rosenstock@gmail.com, faisal.latif@intel.com,
	linux-driver@qlogic.com, blaschka@linux.vnet.ibm.com,
	sony.chacko@qlogic.com, gregory.v.rose@intel.com,
	bhutchings@solarflare.com, xiyou.wangcong@gmail.com,
	jitendra.kalsaria@qlogic.com, divy@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, linux390@de.ibm.com, kaber@trash.net
To: jiri@resnulli.us
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120815074612.GB1726@minipsycho.orion>
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

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 15 Aug 2012 09:46:12 +0200

> You are probably right. I'm not sure how to handle this correctly
> though. Adding some hard limit number might not be correct.

I would just use a hard limit of something like 8 for now, and if we
need to expand this limit we can consider how to do so with real known
usage in mind rather than pure speculation.
