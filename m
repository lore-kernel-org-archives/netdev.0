From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 12:26:23 -0700
Message-ID: <428A455F.8060700@candelatech.com>
References: <20050517.104947.112621738.davem@davemloft.net>	<m1zmut7l5q.fsf@muc.de>	<200505171457.38719.jheffner@psc.edu> <20050517.120950.74749758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@muc.de, netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050517.120950.74749758.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 17 May 2005 14:57:38 -0400
> 
> 
>>It would be better still to have a per-route packet reassembly timeout in 
>>milliseconds.
> 
> 
> I agree.  And if we can setup the infrastructure such that the
> drivers can indicate the speed of the link they are communicating
> on, then we can set sane default values on the automatically
> created subnet routes.

I assume you mean more than local physical link speed?  Imagine:

GigE server -- gige-core -- 10bt hub -- gige-core -- gige client

Now, this particular setup would be lame, but the 10bt hub could
really be a bridged WAN, wireless or other slow and not-so-easily
upgraded network link.

Local link speed is relatively easy to figure out using ethtool for the
NICs that support it at least....

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
