From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Fri, 23 Jul 2004 03:00:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41006344.3070402@trash.net>
References: <40F34740.5040100@trash.net>	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>	<20040712205037.573411c0.davem@redhat.com>	<40F4862D.3070802@trash.net>	<40F4AC8B.40706@trash.net>	<20040721143110.4ab944bf.davem@redhat.com>	<41004F76.1080807@trash.net> <20040722171752.341d2476.davem@redhat.com> <41006150.9000702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
        netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41006150.9000702@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> David S. Miller wrote:
>> We could bug check this in psched calibration, in fact I think
>> we should.
> 
> 
> Done by this patch. I used BUG_ON instead of just printing a warning
> because using packet schedulers after this error will cause a division
> by zero.

Please drop this patch, psched_calibrate_clock already checks if
rdelay > delay a couple of lines above.

> Regards
> Patrick
