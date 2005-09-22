From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 17:50:49 +0200
Message-ID: <4332D2D9.7090802@cosmosbay.com>
References: <43308324.70403@cosmosbay.com> <200509221454.22923.ak@suse.de>
	<20050922125849.GA27413@infradead.org>
	<200509221505.05395.ak@suse.de>
	<Pine.LNX.4.62.0509220835310.16793@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Christoph Lameter <clameter@engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509220835310.16793@schroedinger.engr.sgi.com>
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

Christoph Lameter a =E9crit :
>=20
> It should really be do_set_mempolicy instead to be cleaner. I got a pat=
ch=20
> here that fixes the policy layer.
>=20
> But still I agree with Christoph that a real vmalloc_node is better. Th=
ere=20
> will be no fuzzing around with memory policies etc and its certainly=20
> better performance wise.

vmalloc_node() should be seldom used, at driver init, or when a new ip_ta=
bles=20
is loaded. If it happens to be a performance problem, then we can optimiz=
e it.
Why should we spend days of work for a function that is yet to be used ?

Eric
