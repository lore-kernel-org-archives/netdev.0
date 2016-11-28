From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] bpf: samples: Fix compile of test_lru_dist.c
Date: Mon, 28 Nov 2016 19:36:46 +0000
Message-ID: <CY4PR15MB1144E4DA69FF7DCB37F74772D58A0@CY4PR15MB1144.namprd15.prod.outlook.com>
References: <1480307539-30187-1-git-send-email-dsa@cumulusnetworks.com>,<583BF623.7030103@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Alexei Starovoitov <ast@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48607 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752099AbcK1ThY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:37:24 -0500
In-Reply-To: <583BF623.7030103@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, Nov 28, 2016 at 10:17:23AM +0100, Daniel Borkmann wrote:
> On 11/28/2016 05:32 AM, David Ahern wrote:
> >Build of samples/bpf on debian/jessie fails with:
> >
> >   HOSTCC  /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.o
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c: In function =91main=
=92:
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: error: variabl=
e =91r=92 has initializer but incomplete type
> >   struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
> >          ^
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:21: error: =91RLI=
M_INFINITY=92 undeclared (first use in this function)
> >   struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
> >                      ^
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:21: note: each un=
declared identifier is reported only once for each function it appears in
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: exces=
s elements in struct initializer
> >   struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
> >          ^
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: (near=
 initialization for =91r=92)
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: exces=
s elements in struct initializer
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: (near=
 initialization for =91r=92)
> >/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:16: error: storag=
e size of =91r=92 isn=92t known
> >   struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
> >
> >Add sys/resource.h to the include list
> >
> >Fixes: 5db58faf989f ("bpf: Add tests for the LRU bpf_htab")
> >Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> >Cc: Martin KaFai Lau <kafai@fb.com>
>
> Ran into the same issue, fixed here already:
>
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?i=
d=3De00c7b216f34444252f3771f7d4ed48d4f032636

Thanks for David's report/patch and the earlier Daniel's fix.  Sorry that I
missed it since it compiles fine in my current dev setup (CentOS6).  I
can also reproduce in my newer arch-linux setup.

--Martin
