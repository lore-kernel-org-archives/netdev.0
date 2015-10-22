From: Jeffrey Merkey <jeffmerkey@gmail.com>
Subject: Re: igmp broadcast storm Red Hat EL7 3.1 Kernel
Date: Thu, 22 Oct 2015 14:39:26 -0600
Message-ID: <CA+ekxPVYK2pD67VaP0Sg9pon5EDTU8m6Xy4g3f_MbAusbBV_Uw@mail.gmail.com>
References: <CA+ekxPUBfhBTXwfO1=M3f6siqieBgJsiHs2DbJfgC72ogu3UZw@mail.gmail.com>
	<CAM_iQpUTCpG3YeSvuJTdNAuAjoBObcObYNGKeHrbfR4g+5B7yA@mail.gmail.com>
	<CA+ekxPUHbcRn3jAUJcy1jnsF8YJrkTJEqBabiiSFRW5fhHywXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ekxPUHbcRn3jAUJcy1jnsF8YJrkTJEqBabiiSFRW5fhHywXQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/31/15, Jeffrey Merkey <jeffmerkey@gmail.com> wrote:
> I was able to reproduce it last night with 2.6.32 on Centos 6.3 so it
> does not seem confined to just the 3.X tree.  I think this is
> something that's been lurking in the kernel for years and just has a
> hard time showing up.   Bugs that go away on their own come back on
> their own.
>
> I got a trace of the traffic but need one of the os.  I'll attempt to
> get a trace of this again since I seem to be able to reproduce it by
> routing NetFlix traffic through the router while I am streaming live
> videos on Linux.
>
> I will setup the system to trap the bug and post the traces.
>
> Jeff
>
>
> On 8/31/15, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> (Cc'ing netdev)
>>
>> On Sat, Aug 29, 2015 at 3:50 PM, Jeffrey Merkey <jeffmerkey@gmail.com>
>> wrote:
>>> When installing Centos 7 running kernel 3.1 (Centos 7 distro) the
>>> system generates an igmp broadcast storm which locks up and knocks
>>> down a Century Link DSL router.  Powering the router off clears the
>>> broadcast storm.
>>>
>>> The bug is kernel related and resembles very closely another bug seen
>>> about 10 years ago with Caldera's distro's on 2.4.  The bug occurs on
>>> the ia32 beta build.  The bug DOES NOT exist in the 64 bit x86_64
>>> versions.    I will attempt to debug it further since I have my own
>>> debugger and try to run it down and provide more info.
>>>
>>
>> A reproducer and/or bisect would help a lot.
>>
>> Thanks.
>>
>

I got to the bottom of this, however, I am not convinced it's a bug in
linux any more than configuring a bridge in a loop is a bug.  I
addressed it to the ISP since this is where the problem lies, even
though Linux contributes routed traffic to the problem.

Jeff
