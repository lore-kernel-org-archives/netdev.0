From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Mon, 30 Aug 2004 18:20:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4133A811.1010009@pobox.com>
References: <20040830045441.GA7415@jm.kir.nu> <20040830165026.GD29492@bougret.hpl.hp.com> <413363CB.7060807@pobox.com> <20040830174215.GA32132@bougret.hpl.hp.com> <41336A28.9010608@pobox.com> <20040830220105.GY22126@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com,
        hostap@shmoo.com, Pedro Ramalhais <ramalhais@serrado.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040830220105.GY22126@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> On Mon, Aug 30, 2004 at 01:55:52PM -0400, Jeff Garzik wrote:
> 
>>Jean Tourrilhes wrote:
> 
> 
> <-- snip -->
> 
>>>	Also, I'm not clear how the stuff in wireless-2.6 is supposed
>>>to trickle into the other trees (netdev-2.6, -mm and Linus's), and how
>>>to better link it with the CVS of the various drivers involved.
>>
>>Less of a trickle than a flood:  wireless-2.6 should be the target for 
>>development of shared wireless stack code.  As several drivers are 
>>currently using bits of HostAP, for example, wireless-2.6 should be a 
>>focal point for patches that modify these drivers to instead share the 
>>same code.
>>
>>Once this generic work is done, it would get pushed all at once to 
>>netdev-2.6, where it would receive testing in -mm.  Then, later, pushed 
>>to mainline.
>>
>>	Jeff
> 
> 
> Beides wpa_supplicant from hostap code (which is actually going into
> WE18) what other code re-use is on the roadmap as of yet for wireless-2.6?

Intel Centrino driver is re-using chunks of HostAP, and I'm looking at 
doing so for the RealTek 8180 driver I am about to publish.


> Also who is coordinating this?

The same person who coordinates the kernel at large... no one ;-)

	Jeff
