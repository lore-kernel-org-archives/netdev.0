From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint
 trace_tcp_retransmit_synack()
Date: Fri, 27 Oct 2017 05:06:28 +0000
Message-ID: <D81267F3-4447-4375-B2A8-06F92FAF4ACD@fb.com>
References: <201710261134.MUf5E7cp%fengguang.wu@intel.com>
 <2552809E-4EBC-4F3D-94A4-41BE0ECB27C2@fb.com>
 <CAM_iQpVzGpype9ytprzF9zcigZ6ckE03SYnGPdfSxUQRgqV82Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: kbuild test robot <lkp@intel.com>,
        David Miller <davem@davemloft.net>,
        "kbuild-all@01.org" <kbuild-all@01.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        Martin Lau <kafai@fb.com>, Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "liu.song.a23@gmail.com" <liu.song.a23@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60596 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750795AbdJ0FGh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 01:06:37 -0400
In-Reply-To: <CAM_iQpVzGpype9ytprzF9zcigZ6ckE03SYnGPdfSxUQRgqV82Q@mail.gmail.com>
Content-Language: en-US
Content-ID: <CD3EE99C71C9B24A82D2340CBCF72F69@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 26, 2017, at 7:01 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>=20
> On Thu, Oct 26, 2017 at 4:50 PM, Song Liu <songliubraving@fb.com> wrote:
>> In this case, we are putting CONFIG_IPV6 in TRACE_EVENT macro, which gen=
erates
>> warnings like:
>>=20
>> ./include/trace/events/tcp.h:274:1: error: directive in argument list
>> ./include/trace/events/tcp.h:281:1: error: directive in argument list
>>=20
>> Seems these warning cannot be easily avoided. This is also the same patt=
ern we
>> have been using in include/trace/events/tcp.h.
>=20
> Hmm, we use the same so why it only complains about this one?\

sparse reports same warning for all the lines in tcp.h. Don't know why
kbuild test bot only complains about this patch.=20

>=20
>>=20
>> Any suggestions on how shall we proceed from here?
>>=20
>=20
> I think this warning is harmless, so perhaps not worthy time to
> shut it up, unless sparse provides a simple way to do so.
