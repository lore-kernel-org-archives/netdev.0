From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Mon, 18 Aug 2003 20:07:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F416A5E.2060302@pobox.com>
References: <20030815154608.56cf0551.shemminger@osdl.org> <20030815230546.GA31831@bougret.hpl.hp.com> <20030816052048.5858d68a.davem@redhat.com> <20030817001405.GA1916@bougret.hpl.hp.com> <20030816175851.58a2c179.davem@redhat.com> <20030817011131.GA2120@bougret.hpl.hp.com> <20030818090313.7f153d7a.shemminger@osdl.org> <20030818165024.GB5992@bougret.hpl.hp.com> <20030818165321.GH24693@gtf.org> <20030818170850.GE5992@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com, lists@mdiehl.de
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20030818170850.GE5992@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> On Mon, Aug 18, 2003 at 12:53:21PM -0400, Jeff Garzik wrote:
> 
>>On Mon, Aug 18, 2003 at 09:50:24AM -0700, Jean Tourrilhes wrote:
>>
>>>	You can use irtty-sir with a cross-over serial cable between
>>>two PCs. IrLAN is a bit flaky and no longer maintained, I would
>>>recommend to try IrNET or RfCOMM.
>>
>>Can we remove IrLAN in 2.6, then?  :)
>>
>>	Jeff
> 
> 
> 	The problem is that we don't have another implementation of
> IrLAN. There are a few devices that talk IrLAN (NetBeamIr, Win95), and
> for those there is no alternative and IrLAN works good enough with
> them (I test it every few months). No need to remove it if it still
> works...

No argument.  IrLAN definitely sounds like it should stay.


> 	If you really are in cleanup mood, you can kill :
> 		o irtty (broken - replaced by irtty-sir + sir-dev)
> 		o toshoboe (no spinlock - replaced by donauboe)
> 		o smc-ircc (flaky - replaced by smsc-ircc2)
> 		o ep7211_ir (obsolete hardware, unmaintained)
> 	Happy ?

hehe :)

Given this list, I would be ok with removing the first three, if you and 
others are ok with it.  If something's been replaced, I don't have any 
problem removing it.  If something doesn't have a replacement, like 
IrLAN or ep7211_ir, Linux generally leans towards not removing that code 
(retrocomputing!), so I was perhaps a bit hasty in suggesting that.  But 
that's why we have discussion ;-)

	Jeff
