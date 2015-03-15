From: Oded Gabbay <oded.gabbay@amd.com>
Subject: Re: Linux XIA - merge proposal
Date: Sun, 15 Mar 2015 12:03:17 +0200
Message-ID: <550558E5.2030309@amd.com>
References: <54F5EF6E.9090303@digirati.com.br>
 <CAErSpo6hUHYXrdB0+1WysD=AMuX3eawqSokTngR4s2tmmuakqA@mail.gmail.com>
 <550301B6.3090302@digirati.com.br> <20150315093752.GA29005@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Dave Airlie <airlied@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>,
	Michel Machado <michel@digirati.com.br>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150315093752.GA29005@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/15/2015 11:37 AM, Greg KH wrote:
> On Fri, Mar 13, 2015 at 11:26:46AM -0400, Michel Machado wrote:
>> On 03/10/2015 01:01 PM, Bjorn Helgaas wrote:
>>>  From my point of view (far outside the networking world and completely
>>> incompetent to judge the merits of XIA), this email seems like a
>>> reasonable starting point for a discussion, and I'm disappointed that
>>> it got shut down so fast.  It might not be in *exactly* the form
>>> people are looking for, but hey, it's an introductory email, and
>>> Michel seems open to constructive feedback.
>>
>>     Thank you for the support, Bjorn.
>>
>>     I've brainstormed with friends questions that could address the concerns
>> that haven't been voiced in this thread, and I answered those questions in
>> our FAQ page:
>>
>>     https://github.com/AltraMayor/XIA-for-Linux/wiki/FAQ
>>
>>     While I would like to have Linux XIA merged, I also don't want to become
>> importunate. So, if nobody else shows interest in this thread, I'm going to
>> leave it to rest.
>
> But you have yet to actually post the code, why give up now, you haven't
> even tried.  A number of people have given you hints here as to what you
> should be doing / trying, to just run away without even attempting it
> seems quite odd and defeatist.
>
> good luck,
>
> greg k-h
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
Hi Michel,

Although I don't know you and I'm not familiar with XIA, I would like to 
encourage you to listen to Greg and continue with your efforts to upstream XIA.

I can tell you, from my recent experience of upstreaming AMD's HSA driver to drm 
(amdkfd), that I understand your response/frustration. However, you need to 
understand that the feedback you got is not because the maintainers/devs don't 
want your code. It is because they want your code to be in the best shape it can 
be before merging it to the kernel. Once it is in the kernel, it is distributed 
to millions of people and it is maintained practically forever.

 From my experience, the major changes that make your code better are usually 
done *before* upstreaming the code. Once the maintainers/devs realize that the 
code has reached some level of compliance with kernel standards, and the code 
can't get any better by leaving it outside the kernel, I'm sure they will accept 
the code. Especially if they will see that you are dedicated to improving it.

Please see this enlightening post from drm maintainer, Dave Airlie, about trying 
to push code to upstream kernel:
http://airlied.livejournal.com/80112.html

It is called:
"you have a long road to walk, but first you have to leave the house (or why 
publishing code is STEP ZERO)."

BTW, I believe I was one of the reasons he wrote that post (it was published 
shortly after I published amdkfd's code) :)

So bottom line, keep working on it. People gave you pointers what to do. Follow 
that and don't give up. In the end, I'm sure you will be very happy once the 
code is merged into the mainline kernel.

Good luck,

	Oded
