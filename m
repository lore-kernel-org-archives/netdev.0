From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] rtl8xxxu: mark expected switch fall-throughs
Date: Thu, 12 Oct 2017 07:32:44 +0300
Message-ID: <87po9touj7.fsf@kamboji.qca.qualcomm.com>
References: <20171010193027.GA23108@embeddedor.com>
        <5f5f0f54-d901-90be-9025-0a1c4b909368@gmail.com>
        <87o9peqdo2.fsf@kamboji.qca.qualcomm.com>
        <eb89f2ad-f2d5-b97f-c224-daf3953d912c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <eb89f2ad-f2d5-b97f-c224-daf3953d912c-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Jes Sorensen's
        message of "Wed, 11 Oct 2017 09:34:51 -0400")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 10/11/2017 04:41 AM, Kalle Valo wrote:
>> Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>
>>> On 10/10/2017 03:30 PM, Gustavo A. R. Silva wrote:
>>>> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
>>>> where we are expecting to fall through.
>>>
>>> While this isn't harmful, to me this looks like pointless patch churn
>>> for zero gain and it's just ugly.
>>
>> In general I find it useful to mark fall through cases. And it's just a
>> comment with two words, so they cannot hurt your eyes that much.
>
> I don't see them being harmful in the code, but I don't see them of
> much use either. If it happened as part of natural code development,
> fine. My objection is to people running around doing this
> systematically causing patch churn for little to zero gain.

We do receive quite a lot these kind of cleanup patches found with
various analysers and tools. I guess one could classify those as churn
but I think the net result is still very much on the positive side. And
this patch in particular seems useful for me and I think we should take
it.

-- 
Kalle Valo
