From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Thu, 20 Apr 2017 17:39:14 +0200
Message-ID: <CAAeHK+yzCYZ+OU+eTpNLy-_X=7HSNUDML6jcVBKK9sxJ2ByORg@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com>
 <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
 <CACT4Y+Z6f4aOxMZW44WXdYEyDJbGBYLnjKsHBXfK800h+EkrxA@mail.gmail.com>
 <2270c1ca-9481-60c1-9c29-87669223bded@cumulusnetworks.com>
 <CACT4Y+aUROZgAczRfntp5Rgvzcypviz5ZWBPdE6MWSiO0-3jEg@mail.gmail.com>
 <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com>
 <580392d8-fa33-67bb-c5d6-27d262f1646a@cumulusnetworks.com>
 <CAAeHK+zZb=K4X9=NmSWQJL8bpgMbXoG+h4RasAyYDr+C5pkVYA@mail.gmail.com>
 <CAM_iQpXyDN5GD+QLmWgJSc0bqV0ViK5LxSdwAV3XsHWr6vLJ2Q@mail.gmail.com>
 <1dad955e-28c1-3f02-8876-90cce4a7d1f8@cumulusnetworks.com>
 <CACT4Y+amFHj1DV3pmj+eJVxg52+GLdE-fEin5M86dOKubea7DQ@mail.gmail.com>
 <CAAeHK+zWO1COcZDp9q4eHP9YN9Qv8CXLOJu8dJgCbihcFSK3jg@mail.gmail.com>
 <CAAeHK+zSe82vc5gCRgr_EoUwiALPnWVdWJBPwJZBpbxYz=kGJw@mail.gmail.com> <623b6343-14f4-945d-a1bd-c9971b9566c2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <623b6343-14f4-945d-a1bd-c9971b9566c2@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2017 at 5:35 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 4/20/17 9:28 AM, Andrey Konovalov wrote:
>> This one seems to be much closer to what Dmitry reported intially.
>
> does not repro here; I ran in a loop and nothing.

You use the attached config, right?

>
> can you send output of "sysctl -a --pattern 'net.ipv6'"

Uploaded here:
https://gist.github.com/xairy/7b6988c9cd8fda5458005df05584ff27
