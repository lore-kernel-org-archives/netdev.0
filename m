From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Fri, 3 Mar 2006 12:00:54 +1100
Message-ID: <17415.38214.77398.803632@cargo.ozlabs.ibm.com>
References: <20060131041055.5623C68A46@ozlabs.org>
	<20060131042903.GF28896@krispykreme> <44074A22.8060705@us.ibm.com>
	<200603031122.51174.michael@ellerman.id.au>
	<20060302163423.f758c5bc.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: michael@ellerman.id.au, linuxppc64-dev@ozlabs.org, jgarzik@pobox.com,
	anton@samba.org, netdev@vger.kernel.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060302163423.f758c5bc.rdunlap@xenotime.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Randy.Dunlap writes:

> E.g., could the hypervisor know when one of it's virtual OSes
> dies or reboots and release its resources then?

I think the point is that with kexec, the same virtual machine keeps
running, so the hypervisor doesn't see the OS dying or rebooting.

Paul.
