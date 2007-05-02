From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: patches for 2.6.22
Date: Wed, 2 May 2007 09:12:36 -0500
Message-ID: <42664CF1-75AF-4343-BC50-870D3614C683@kernel.crashing.org>
References: <17969.56735.644629.328360@cargo.ozlabs.ibm.com>
	<20070430145119.6713490e.kim.phillips@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Paul Mackerras <paulus@samba.org>, jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20070430145119.6713490e.kim.phillips@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Apr 30, 2007, at 2:51 PM, Kim Phillips wrote:

> On Fri, 27 Apr 2007 21:25:19 +1000
> Paul Mackerras <paulus@samba.org> wrote:
>
>> If anyone has patches that I haven't picked up yet which they think
>> should go into 2.6.22, please send me either a pointer to the
>
> these were missed:
>
> [PATCH 1/4 v5] powerpc: document phy-connection-type property
> Tue Apr 24 07:26:10 EST 2007
> http://ozlabs.org/pipermail/linuxppc-dev/2007-April/034669.html

ok.

> [PATCH 2/4 v4] powerpc: replace undocumented interface properties  
> in dts files
> Tue Apr 24 07:26:14 EST 2007
> http://ozlabs.org/pipermail/linuxppc-dev/2007-April/034670.html

I have issues with this since it looks like the current ucc driver in  
linus's tree is using a previous rev of your patch and thus using  
interface-type and max-speed still.

> [PATCH 3/4] powerpc: Add 'mdio' to bus scan id list for platforms  
> with QE UEC
> Wed Apr 11 07:56:49 EST 2007
> http://ozlabs.org/pipermail/linuxppc-dev/2007-April/034163.html

ok

>
> [PATCH 4/4] powerpc: turn on corresponding PHY drivers in QE UEC  
> platforms defconfigs
> Wed Apr 11 07:56:53 EST 2007
> http://ozlabs.org/pipermail/linuxppc-dev/2007-April/034164.html

ok

I'll pull patches 1, 3, 4 and wait on the dts changes until you sort  
of the ucc driver issues with Jeff.

- k
