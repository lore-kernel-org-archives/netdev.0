From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones
Date: Thu, 19 May 2005 14:07:04 -0500
Message-ID: <200505191407.04650.jdmason@us.ibm.com>
References: <200505191106.53136.jdmason@us.ibm.com> <200505191247.55138.jdmason@us.ibm.com> <20050519.115832.111205328.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: util@deuroconsult.ro, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050519.115832.111205328.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 19 May 2005 01:58 pm, David S. Miller wrote:
> From: Jon Mason <jdmason@us.ibm.com>
> Date: Thu, 19 May 2005 12:47:55 -0500
>
> > My point is that some features the user might want enabled regardless of
> > whether all devices support them.  An example of this is where a system
> > has hardware checksum support for all devices except one.  In this case,
> > it would be benefitial to have this device do the checksum in software
> > (via skb_checksum_help() call in dev_queue_xmit()).
>
> If "SG and checksumming is so common these days" as others have
> stated, what you are describing is a totally uncommon scenerio.  

Uncommon, yes, but very possible and I am trying to mitigate the performance 
effects of this case.

> What 
> Catalin is proposing is infinitely better than what we have today.

I completely agree Catalin's patch is better than what we have now.  My only 
arguement is that there are some cases where it should be augmented to 
include additional features.
