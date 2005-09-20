From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] Adds sys_set_mempolicy() in include/linux/syscalls.h , Re:
 [PATCH, netfilter] NUMA aware ipv4/netfilter/ip_tables.c
Date: Tue, 20 Sep 2005 23:45:02 +0200
Message-ID: <433082DE.3060308@cosmosbay.com>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
	<432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org
In-Reply-To: <200509201830.20689.ak@suse.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =C3=A9crit :
> On Tuesday 20 September 2005 11:47, Eric Dumazet wrote:
>=20
>=20
>=20
> I would prefer if random code didn't mess with mempolicy internals
> like this. Better just call sys_set_mempolicy()=20
>=20
> -Andi
>=20
>=20


OK but this prior patch seems necessary :

- Adds sys_set_mempolicy() in include/linux/syscalls.h

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
