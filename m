From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII Timing)
Date: Mon, 19 Nov 2007 20:30:06 -0500
Message-ID: <4742389E.5080700@pobox.com>
References: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
	<20071119173652.55e385b2.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>, paulus@samba.org,
	linuxppc-dev@ozlabs.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071119173652.55e385b2.kim.phillips@freescale.com>
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

Kim Phillips wrote:
> On Mon, 5 Nov 2007 12:15:30 -0600
> Kim Phillips <kim.phillips@freescale.com> wrote:
> 
>> Hello all,
>>
>> the following patches fix RGMII timing for rev. 2.1 of the mpc8360,
>> according to erratum #2 (erratum text included below).  Basically the
>> most intrusive part is the addition of two new RGMII Internal Delay
>> modes; one for TX delay only, and the other for RX delay only (i.e, not
>> both at the same time).
>>
>> Please review, and since this affects both netdev and powerpc trees,
>> one maintainer should ack them for the other to push upstream (i.e,
>> Kumar acks them, and Leo picks them up to go through netdev or the
>> other way around; either way is fine with me).  I'm hoping they're
>> trivial enough to go in 2.6.24.
>>
> Kumar, Leo, 
> 
> re-ping due to (a) it's been 2 weeks and (b) Anton Vorontsov has since
> issued his Tested-by.
> 
> Might I suggest Kumar ack the powerpc patches, and Leo/Jeff apply 5/5
> to go through netdev?

FWIW I just got back from vacation...  I'm grabbing what DaveM has 
collected into davem/netdev-2.6.git, and then going from there...

	Jeff
