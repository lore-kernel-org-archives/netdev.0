From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH] tc/mqprio: Offload mode and shaper options in
 mqprio
Date: Tue, 31 Oct 2017 18:20:46 +0100
Message-ID: <20171031182046.23eda44c@shemminger-XPS-13-9360>
References: <150906256227.24207.1663946225760686391.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        jiri@resnulli.us, jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:54643 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753474AbdJaRVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:21:11 -0400
Received: by mail-lf0-f51.google.com with SMTP id a2so19899445lfh.11
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:21:11 -0700 (PDT)
In-Reply-To: <150906256227.24207.1663946225760686391.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Oct 2017 17:02:42 -0700
Amritha Nambiar <amritha.nambiar@intel.com> wrote:

> This patch was previously submitted as RFC. Submitting this as
> non-RFC now that the tc/mqprio changes are accepted in net-next.
>=20
> Adds new mqprio options for 'mode' and 'shaper'. The mode
> option can take values for offload modes such as 'dcb' (default),
> 'channel' with the 'hw' option set to 1. The new 'channel' mode
> supports offloading TCs and other queue configurations. The
> 'shaper' option is to support HW shapers ('dcb' default) and
> takes the value 'bw_rlimit' for bandwidth rate limiting. The
> parameters to the bw_rlimit shaper are minimum and maximum
> bandwidth rates. New HW shapers in future can be supported
> through the shaper attribute.
>=20
> # tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
>   queues 4@0 4@4 hw 1 mode channel shaper bw_rlimit\
>   min_rate 1Gbit 2Gbit max_rate 4Gbit 5Gbit
>=20
> # tc qdisc show dev eth0
>=20
> qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>              queues:(0:3) (4:7)
>              mode:channel
>              shaper:bw_rlimit   min_rate:1Gbit 2Gbit   max_rate:4Gbit 5Gb=
it
>=20
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>


Please build test your patch with compiler checks enabled....

    CC       q_mqprio.o
In file included from /usr/include/string.h:635:0,
                 from q_mqprio.c:20:
In function =E2=80=98memcpy=E2=80=99,
    inlined from =E2=80=98mqprio_print_opt=E2=80=99 at q_mqprio.c:237:2:
/usr/include/x86_64-linux-gnu/bits/string3.h:53:10: warning: call to __buil=
tin___memcpy_chk will always overflow destination buffer
   return __builtin___memcpy_chk (__dest, __src, __len, __bos0 (__dest));
          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
