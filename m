From: Sachin Sant <sachinp@in.ibm.com>
Subject: Re: 2.6.31-rc5-git2 crash [net/core/flow.c:flow_cache_new_hashrnd]
Date: Tue, 11 Aug 2009 10:55:00 +0530
Message-ID: <4A8100AC.30404@in.ibm.com>
References: <4A78292A.5000607@in.ibm.com> <4A783B1F.7000602@in.ibm.com>
	<1249395350.8016.5.camel@concordia>
	<1249597385.24311.10.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1249597385.24311.10.camel@pasglop>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> BTW. Corruption looks like bi_recs... ie, broken yaboot. This was fixed
> recently, yaboot would eventually crap over the kernel for certain sizes
> of the kernel image.
>
> 0x1010 = BI_FIRST
> 0x1013 = BI_BOOTLOADER_ID followed by 0x7961626f6f74 which is
> "yaboot" :-)
> 0x1016 = BI_MACHTYPE
>   
Was away from office for few days.

Thanks for the help. The machine under test is running
F11. I will try out the latest yaboot.

Thanks
-Sachin



-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------
