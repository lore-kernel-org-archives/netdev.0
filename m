From: Oded Gabbay <oded.gabbay@amd.com>
Subject: Re: Linux XIA - merge proposal
Date: Wed, 18 Mar 2015 12:27:30 +0200
Message-ID: <55095312.5080802@amd.com>
References: <54F5EF6E.9090303@digirati.com.br>
 <CAErSpo6hUHYXrdB0+1WysD=AMuX3eawqSokTngR4s2tmmuakqA@mail.gmail.com>
 <550301B6.3090302@digirati.com.br> <20150315093752.GA29005@kroah.com>
 <55081D48.3000407@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Michel Machado <michel@digirati.com.br>,
	Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55081D48.3000407@digirati.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/17/2015 02:25 PM, Michel Machado wrote:
> On 03/15/2015 05:37 AM, Greg KH wrote:
>> On Fri, Mar 13, 2015 at 11:26:46AM -0400, Michel Machado wrote:
>>> On 03/10/2015 01:01 PM, Bjorn Helgaas wrote:
>>>>  From my point of view (far outside the networking world and completely
>>>> incompetent to judge the merits of XIA), this email seems like a
>>>> reasonable starting point for a discussion, and I'm disappointed that
>>>> it got shut down so fast.  It might not be in *exactly* the form
>>>> people are looking for, but hey, it's an introductory email, and
>>>> Michel seems open to constructive feedback.
>>>
>>>     Thank you for the support, Bjorn.
>>>
>>>     I've brainstormed with friends questions that could address the
>>> concerns
>>> that haven't been voiced in this thread, and I answered those
>>> questions in
>>> our FAQ page:
>>>
>>>     https://github.com/AltraMayor/XIA-for-Linux/wiki/FAQ
>>>
>>>     While I would like to have Linux XIA merged, I also don't want to
>>> become
>>> importunate. So, if nobody else shows interest in this thread, I'm
>>> going to
>>> leave it to rest.
>>
>> But you have yet to actually post the code, why give up now, you haven't
>> even tried.  A number of people have given you hints here as to what you
>> should be doing / trying, to just run away without even attempting it
>> seems quite odd and defeatist.
>
> Hi Greg,
>
>     After reading your e-mail, I realized that I hadn't really
> understood the feedback that I've received. I'm going to follow your
> advice. Figuring out how to break our codebase in series of patches is
> going to take sometime, but I intend to get it moving.
>
> [ ]'s
> Michel Machado
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Hi Michel,
If you want an example of how to break a fairly medium+ 
code-base/driver, I believe amdkfd is a good example. Originally, I had 
dumped 80+ patches, but after getting some flames & help from drm devs, 
I rearranged them into a nicely 25 patches:

1. Several patches that implements helper functions in other drivers 
(mm, iommu, radeon)
2. Patch to add IOCTL definitions (kfd_ioctl.h)
3. Patch to add skeleton code base of driver
4. Several patches that add different modules in the amdkfd driver
5. Several patches that implement the IOCTLs in the amdkfd drivers

See this link for the final set that was merged into 3.19-rc1: 
http://cgit.freedesktop.org/~gabbayo/linux/?h=amdkfd-v6

Take a look from commit "Merge branch 'drm-next-3.19'  to the HEAD of 
the log.

If you need additional advice, you can contact me.

	Oded
