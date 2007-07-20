From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] Allow LSM to use IP address/port number.
Date: Fri, 20 Jul 2007 17:44:19 +0200
Message-ID: <46A0D853.30803@trash.net>
References: <20070709.002629.28788394.davem@davemloft.net> <200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp> <Line.LNX.4.64.0707091842360.9417@d.namei> <20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net> <Line.LNX.4.64.0707091940450.10029@d.namei> <200707210011.HBI60217.FUNOWSFPGEt@I-love.SAKURA.ne.jp> <Line.LNX.4.64.0707201124070.7319@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <Line.LNX.4.64.0707201124070.7319@d.namei>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Sat, 21 Jul 2007, Tetsuo Handa wrote:
>
>   
>> I can't use netfilter infrastructure because
>> it is too early to know who the recipant process of the packet is.
>>     
>
> I think the way forward on this is to re-visit the idea of providing a 
> proper solution for the incoming packet/user match problem.
>
> I posted one possible solution a couple of years ago (skfilter):
> http://lwn.net/Articles/157137/
>
> I think there has been some recent discussion by netfilter developers 
> about this issue, so perhaps you could talk to them (cd'd Patrick)
>   

Even with socket filters netfilter doesn't know the final receipient
process, that is not known until it calls recvmsg and the data is read,
which is too late for netfilter.

Quoting Tetsuo:

 > > So, my approach is not using security context associated with a socket

> > but security context associated with a process.


Isn't the socket context derived from the process context?



