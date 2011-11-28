From: Martin Casado <casado-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 07:27:22 -0800
Message-ID: <4ED3A85A.1030003@nicira.com>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<1322488954.7338.66.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322488954.7338.66.camel@mojatatu>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


>> However, what's more worrying for me right now is the gaping
>> DoS opportunities that exist in the patch as is.
>>
>> In particular, the whole design principle of punting all new
>> flows to user-space is an excellent way of attacking the system.
> Indeed this is an issue with openflow in general.
> The general solution is to rate limit how much goes to the controller
> but even that is insufficient.
>
This is a common misunderstanding about OpenFlow.  It does not require 
the first packet of each flow to go to the controller.  In fact, no 
production system I'm aware of does this.  Generally OpenFlow-based 
solutions targeted at large environments (e.g. data center, or WAN)  
send only traditional control traffic to the controller (e.g. BGP or 
OSPF), or none at all.
.martin

-- 
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Martin Casado
Nicira Networks, Inc.
www.nicira.com
cell: 650-776-1457
~~~~~~~~~~~~~~~~~~~~~~~~~~~
