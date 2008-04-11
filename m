From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Fri, 11 Apr 2008 11:48:37 -0500
Message-ID: <47FF9665.7020403@freescale.com>
References: <20080311171045.GB4684@localhost.localdomain>	<82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org>
	<20080411160654.GA25506@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080411160654.GA25506@polina.dev.rtsoft.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Anton Vorontsov wrote:
> On Fri, Apr 11, 2008 at 09:13:36AM -0500, Kumar Gala wrote:
>> On Mar 11, 2008, at 12:10 PM, Anton Vorontsov wrote:
>>> - get rid of `model = "UCC"' in the ucc nodes
>>>  It isn't used anywhere, so remove it. If we'll ever need something
>>>  like this, we'll use compatible property instead.
>>> - replace cell-index and device-id properties by fsl,ucc.
>>>
>>> Drivers are modified for backward compatibility's sake.
>> I'd prefer we use cell-index and not introduce "fsl,ucc".  I'm ok with  
>> dropping device-id and model (its implied in the compatiable).
> 
> Ok. Here it is. netdev and linux-serial Cc'ed.

Do we want the first UCC to have a cell-index of 1?  Maybe we should fix this
off-by-one error once and for all, and number all UCCs from 0?

-- 
Timur Tabi
Linux kernel developer at Freescale
