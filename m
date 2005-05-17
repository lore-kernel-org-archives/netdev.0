From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 12:21:47 -0700
Message-ID: <428A444B.8000608@hp.com>
References: <20050517.104947.112621738.davem@davemloft.net>	<m1zmut7l5q.fsf@muc.de> <200505171457.38719.jheffner@psc.edu> <20050517.120950.74749758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
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

Does the ingress link really tell us all that much about the path a given 
datagram's fragments took to get to us?  Even if the source IP is ostensibly a 
local one?

rick jones
