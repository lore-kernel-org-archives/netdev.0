From: Eran Mann <emann@mrv.com>
Subject: Re: VLAN patches
Date: Mon, 07 Oct 2002 09:32:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA1389E.6070006@mrv.com>
References: <20021006.194654.35505461.davem@redhat.com>	<3DA1010A.8020202@candelatech.com>	<3DA13332.4080109@mrv.com> <20021007.000627.50595749.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, hadi@cyberus.ca, Bjorn.Andersson@ebc.ericsson.se,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Eran Mann 
>    
>    Regarding the 0 VID it is indeed used for priority-only frames. 
>    Shouldn't it be supported by alowing the user to configure a priority 
>    map for the ethernet device (rather than creating another user-visible 
>    device?
> 
> I don't have any opinion about this, besides the fact that if
> the device based interface we have now can do whatever the user
> wants we should not add a new configuration mechanism just to provide
> some alias that effectively accomplishes the same task.
> 
I was thinking more in the line of:
# vconfig set_egress_map eth0 XX YY
etc...
(once CONFIG_VLAN_8021Q=y|m ofcourse)
-- 
Eran Mann
Senior Software Engineer
MRV International
Tel: 972-4-9936297
Fax: 972-4-9890430
www.mrv.com
