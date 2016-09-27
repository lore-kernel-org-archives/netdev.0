From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_osf: Use explicit member assignment
 to avoid implicit no padding rule
Date: Tue, 27 Sep 2016 14:05:00 +0800
Message-ID: <CAML_gOcVWerP2keCiqeTUt5QN-gbqATpTUsK-xPX=RnJoc8OBQ@mail.gmail.com>
References: <1474951193-3486-1-git-send-email-fgao@ikuai8.com>
 <CAML_gOcQt3MuDw3JAXYab1bKFaRuKgVO4jBaM22NOCShVoKmeA@mail.gmail.com> <CA+6hz4rZ5GF3MuVrywA87xQ-idq9iCL-cmmgA0sLwuHUp2PEbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+6hz4rZ5GF3MuVrywA87xQ-idq9iCL-cmmgA0sLwuHUp2PEbA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Feng,

2016-09-27 14:00 GMT+08:00 Gao Feng <fgao@ikuai8.com>:
> Hi Liping,
>
>>
>> This xt_osf_user_finger{} is carefully designed, no padding now, and
>> will not be changed in the future, otherwise backward compatibility will
>> be broken.
>
> Yes, there is no padding now. So it is ok to use memcmp now.
> I am afraid the struct would be modified for other requirements.

This is structure was passed by netlink attribute, so modify it will
break backward compatibility.

>
> If it is never changed forever, it is ok certainly.
>
>>
>> I don't think this convert is necessary, actually it is a little ugly, and will
>> increase the maintenance burden.
>
> I just want the codes don't depend any implicit rule.
>
> It is a tradeoff. If never change, needn't do any convert.
> If may change, the memcmp is a little dangerous.
>
> Regards
> Feng
