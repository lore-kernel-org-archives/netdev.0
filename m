From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Mon, 27 Mar 2006 12:11:16 +1100
Message-ID: <1143421876.7795.2.camel@localhost.localdomain>
References: <20060131041055.5623C68A46@ozlabs.org>
	<20060131042903.GF28896@krispykreme>  <44074A22.8060705@us.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: jgarzik@pobox.com
In-Reply-To: <44074A22.8060705@us.ibm.com>
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

On Thu, 2006-03-02 at 13:40 -0600, Santiago Leon wrote:
> From: Michael Ellerman <michael@ellerman.id.au>
> 
> After a kexec the veth driver will fail when trying to register with the
> Hypervisor because the previous kernel has not unregistered.
> 
> So if the registration fails, we unregister and then try again.
> 
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
> Acked-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Santiago Leon <santil@us.ibm.com>
> ---
> 
>   drivers/net/ibmveth.c |   32 ++++++++++++++++++++++++++------
>   1 files changed, 26 insertions(+), 6 deletions(-)

Looks like this hit the floor. Any chance of getting it into to 2.6.17
Jeff? AFAICT it should still apply cleanly.

cheers

-- 
Michael Ellerman
IBM OzLabs

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person
