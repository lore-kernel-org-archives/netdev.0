From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] samples/bpf: Fix build breakage with
 map_perf_test_user.c
Date: Fri, 1 Apr 2016 00:16:02 +0530
Message-ID: <20160331184602.GC17907@naverao1-tp.ibm.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <56FD61B6.9000102@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	"David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56FD61B6.9000102@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/03/31 10:43AM, Alexei Starovoitov wrote:
> On 3/31/16 4:25 AM, Naveen N. Rao wrote:
> >Building BPF samples is failing with the below error:
> >
> >samples/bpf/map_perf_test_user.c: In function =E2=80=98main=E2=80=99=
:
> >samples/bpf/map_perf_test_user.c:134:9: error: variable =E2=80=98r=E2=
=80=99 has
> >initializer but incomplete type
> >   struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
> >          ^
> >Fix this by including the necessary header file.
> >
> >Cc: Alexei Starovoitov <ast@fb.com>
> >Cc: David S. Miller <davem@davemloft.net>
> >Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> >Cc: Michael Ellerman <mpe@ellerman.id.au>
> >Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> >---
> >  samples/bpf/map_perf_test_user.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> >diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf=
_test_user.c
> >index 95af56e..3147377 100644
> >--- a/samples/bpf/map_perf_test_user.c
> >+++ b/samples/bpf/map_perf_test_user.c
> >@@ -17,6 +17,7 @@
> >  #include <linux/bpf.h>
> >  #include <string.h>
> >  #include <time.h>
> >+#include <sys/resource.h>
> >  #include "libbpf.h"
> >  #include "bpf_load.h"
>=20
> It's failing this way on powerpc? Odd.

This fails for me on x86_64 too -- RHEL 7.1.

> Such hidden header dependency was always puzzling to me. Anyway:
> Acked-by: Alexei Starovoitov <ast@kernel.org>
>=20
> I'm assuming you want this set to go via 'net' tree, so please resubm=
it
> with [PATCH net 1/4] subjects and cc netdev.

Sure.

>=20
> Reviewing your other patches...

Thanks for your review!

- Naveen
