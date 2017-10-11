From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] rtl8xxxu: mark expected switch fall-throughs
Date: Wed, 11 Oct 2017 09:32:48 -0500
Message-ID: <20171011093248.Horde.Jwmh0VKhmCeOxBgQzLLpYeZ@gator4166.hostgator.com>
References: <20171010193027.GA23108@embeddedor.com>
 <5f5f0f54-d901-90be-9025-0a1c4b909368@gmail.com>
 <87o9peqdo2.fsf@kamboji.qca.qualcomm.com>
 <eb89f2ad-f2d5-b97f-c224-daf3953d912c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Kees Cook <keescook@chromium.org>
To: Jes Sorensen <jes.sorensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <eb89f2ad-f2d5-b97f-c224-daf3953d912c@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jes,

Quoting Jes Sorensen <jes.sorensen@gmail.com>:

> On 10/11/2017 04:41 AM, Kalle Valo wrote:
>> Jes Sorensen <jes.sorensen@gmail.com> writes:
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
>
> Jes


I understand that you think this is of zero gain for you, but as  
Florian Fainelli pointed out:

"That is the canonical way to tell static analyzers and compilers that
fall throughs are wanted and not accidental mistakes in the code. For
people that deal with these kinds of errors, it's quite helpful, unless
you suggest disabling that particular GCC warning specific for that
file/directory?"

this is very helpful for people working on fixing issues reported by  
static analyzers. It saves a huge amount of time when dealing with  
False Positives. Also, there are cases when an apparently intentional  
fall-through turns out to be an actual missing break or continue.

So there is an ongoing effort to detect such cases and avoid them to  
show up in the future by at least warning people about a potential  
issue in their code. And this is helpful for everybody.

Thanks
--
Gustavo A. R. Silva
