From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Mon, 30 Aug 2004 13:55:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41336A28.9010608@pobox.com>
References: <20040830045441.GA7415@jm.kir.nu> <20040830165026.GD29492@bougret.hpl.hp.com> <413363CB.7060807@pobox.com> <20040830174215.GA32132@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com, hostap@shmoo.com,
        Pedro Ramalhais <ramalhais@serrado.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040830174215.GA32132@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> On Mon, Aug 30, 2004 at 01:28:43PM -0400, Jeff Garzik wrote:
> 
>>Jean Tourrilhes wrote:
>>
>>>	Don't worry, I'll fix that. Anyway, WE-17 is pending in Jeff's
>>>tree, and I don't think he will make major changes to it.
>>
>>
>>hehe :)
>>
>>Yep, it's merged in netdev-2.6 (and thus -mm as well), and queued for 
>>upstream.
> 
> 
> 	Thanks ;-)
> 
> 
>>FWIW any 'radical' wireless changes will go into wireless-2.6.  There is 
>>still the stable upstream branch, to which WE patches can continue to be 
>>applied...
> 
> 
> 	If you don't mind, I would like a bit more understanding about
> how much is "radical" and how much is not. I would personally put that
> around "breaking backward compatibility", but you may have other
> ideas.

Yes, as discussed (er, argued :)) radical would include breaking 
backwards compat.


> 	Also, I'm not clear how the stuff in wireless-2.6 is supposed
> to trickle into the other trees (netdev-2.6, -mm and Linus's), and how
> to better link it with the CVS of the various drivers involved.

Less of a trickle than a flood:  wireless-2.6 should be the target for 
development of shared wireless stack code.  As several drivers are 
currently using bits of HostAP, for example, wireless-2.6 should be a 
focal point for patches that modify these drivers to instead share the 
same code.

Once this generic work is done, it would get pushed all at once to 
netdev-2.6, where it would receive testing in -mm.  Then, later, pushed 
to mainline.

	Jeff
