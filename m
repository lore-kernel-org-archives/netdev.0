From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH v3] net: ethernet: support "fixed-link" DT node on nb8800
 driver
Date: Mon, 08 Feb 2016 15:32:21 +0100
Message-ID: <56B8A6F5.9060409@laposte.net>
References: <56B4A445.7080402@laposte.net>	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>	<yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net>	<yw1xoabvgs7s.fsf@unicorn.mansr.com> <56B4B013.5030407@laposte.net>	<yw1xk2mjgraf.fsf@unicorn.mansr.com> <56B4B81D.3000108@laposte.net>	<yw1xfux7gpol.fsf@unicorn.mansr.com> <56B4BDDA.9010708@laposte.net>	<yw1xbn7vgoux.fsf@unicorn.mansr.com> <56B86F44.3030806@laposte.net> <yw1xfux3fhmq.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?windows-1252?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xfux3fhmq.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/2016 02:37 PM, M=E5ns Rullg=E5rd wrote:
> Sebastian Frias <sf84@laposte.net> writes:
>
>> On 02/05/2016 04:26 PM, M=E5ns Rullg=E5rd wrote:
>>> Sebastian Frias <sf84@laposte.net> writes:
>>>
>>>> On 02/05/2016 04:08 PM, M=E5ns Rullg=E5rd wrote:
>>>>> Sebastian Frias <sf84@laposte.net> writes:
>>>>>
>>>>>> On 02/05/2016 03:34 PM, M=E5ns Rullg=E5rd wrote:
>>>>>>> Sebastian Frias <sf84@laposte.net> writes:
>>>>>>>
>>>>>>>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>>>>>>>
>>>>>>> Please change the subject to something like "net: ethernet: nb8=
800:
>>>>>>> support fixed-link DT node" and add a comment body.
>>>>>>
>>>>>> The subject is pretty explicit for such a simple patch, what els=
e
>>>>>> could I add that wouldn't be unnecessary chat?
>>>>>
>>>>> It's customary to include a description body even if it's little =
more
>>>>> than a restatement of the subject.  Also, while the subject usual=
ly only
>>>>> says _what_ the patch does, the body should additionally state _w=
hy_ it
>>>>> is needed.
>>>>
>>>> I understand, but _why_ it is needed is also obvious in this case;=
 I
>>>> mean, without the patch "fixed-link" cannot be used.
>>>
>>> Then say so.
>>>
>>>> Other patches may not be as obvious/simple and thus justify and
>>>> require more details.
>>>>
>>>> Anyway, I added "Properly handles the case where the PHY is not co=
nnected
>>>> to the real MDIO bus" would that be ok?
>>>
>>> Have you read Documentation/SubmittingPatches?  Do so (again) and p=
ay
>>> special attention to section 2 "Describe your changes."
>>
>> I just sent v5.
>
> Thanks for your patience.

:-)

>
>> If for whatever reason, you or anybody else think that the comment i=
s
>> not good, would you mind proposing a comment that would make everybo=
dy
>> happy so that the patch goes thru?
>> And if you or anybody else does not want the patch, could you please
>> say so as well?
>>
>> I have to admit this process (sending patches and getting it reviewe=
d)
>> could benefit from more clarifications.
>> For example, the process could say that at least 2 reviewers must
>> agree on it (on the comments made to the patch and on the patch
>> itself).
>> I could also say that reviewers are to express not only their opinio=
n
>> but to clearly and unequivocally accept or reject.
>>
>> For instance, right now, it is not clear to me if your comments are
>> "nice to have" or "blocking" the patch.
>> I don't know if the patch is welcome or not, etc.
>> So I submitted v5, but maybe it was not even necessary, it's hard to
>> know where in the submission process we are.
>
> In this case, it's ultimately up to Dave Miller.  He'll take into
> account whatever comments others have made and decide whether he want=
s
> to accept it.

Ok, thanks.

>
>> By the way, I know some people like the command line, email, etc. bu=
t
>> there ought to be other tools better suited for patch review...
>
> Some kernel subsystems use http://patchwork.ozlabs.org/ to track stat=
us
> of various patches.
>

Thanks, I see that netdev is part of it, and that the patches are there=
:

https://patchwork.ozlabs.org/patch/580217/

seems like a slight layer over plain email and mailinglists; I was=20
thinking of something more in the line of https://www.gerritcodereview.=
com/
I believe Google uses Gerrit for Android.
I think Gerrit would probably be too big (and being written in Java,=20
using Prolog and other DSLs, implementing its own Git server in Java,=20
etc, may make some -or lots?- of kernel developers cry :-) )
However, in Gerrit it is easier to know where in the "review" process w=
e=20
are, because people have to explicitly give a score "+/- X" when=20
commenting on a patch.
Also, the diff can operate between different versions of the patches=20
themselves to see if the inlined comments were addressed.
