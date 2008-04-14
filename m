From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Mon, 14 Apr 2008 09:51:29 -0500
Message-ID: <6B2293E0-BE5E-4C2E-9A48-4E91079A7422@kernel.crashing.org>
References: <20080311171045.GB4684@localhost.localdomain>
	<82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org>
	<20080411160654.GA25506@polina.dev.rtsoft.ru>
	<47FF9665.7020403@freescale.com>
	<20080411170657.GA15270@polina.dev.rtsoft.ru>
	<20080411171109.GA16119@polina.dev.rtsoft.ru>
	<47FF9BFE.5000201@freescale.com>
	<20080411172106.GA17786@polina.dev.rtsoft.ru>
	<20080411173100.GA20439@polina.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	Timur Tabi <timur@freescale.com>, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080411173100.GA20439@polina.dev.rtsoft.ru>
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


On Apr 11, 2008, at 12:31 PM, Anton Vorontsov wrote:
> On Fri, Apr 11, 2008 at 09:21:06PM +0400, Anton Vorontsov wrote:
>> On Fri, Apr 11, 2008 at 12:12:30PM -0500, Timur Tabi wrote:
>>> Anton Vorontsov wrote:
>>>
>>>> Or maybe I'm thinking here in terms of "fsl,ucc"... and cell- 
>>>> index is
>>>> indeed should be -1... don't know. Please decide. ;-)
>>>
>>> Well, that's what I was thinking.  cell-index is zero-based, so  
>>> UCC1 should have
>>> cell-index = <0>.
>>>
>>> Of course, this means all the code needs to change, since I think  
>>> device-id is
>>> one-based.
>>
>> Yup. You raised a really good question, because we're _introducing_
>> cell-index for UCC nodes, and if we'll choice wrong numbering scheme
>> now, then there will be no way back w/o breaking backward  
>> compatibility.
>
> Hm... thinking about it more, we're introducing implementation for the
> cell-index, but device tree was "infected" already.
>
> So, too late. :-D

I say leave as you have it (UCC1 == cell-index = <1>).

Changing it so cell-index = <0> is just more confusing w/regards to  
the docs.

- k
