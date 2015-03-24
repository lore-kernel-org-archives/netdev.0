From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Tue, 24 Mar 2015 15:32:05 +0100
Message-ID: <55117565.6080002@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at> <m2twxacw13.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com,
	rusty@rustcorp.com.au, mathieu.lacage@gmail.com
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <m2twxacw13.wl@sfc.wide.ad.jp>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 24.03.2015 um 15:25 schrieb Hajime Tazaki:
> At Tue, 24 Mar 2015 14:21:49 +0100,
> Richard Weinberger wrote:
>>
>> Am 24.03.2015 um 14:10 schrieb Hajime Tazaki:
>>  > == More information ==
>>>
>>> The crucial difference between UML (user-mode linux) and this approach
>>> is that we allow multiple network stack instances to co-exist within a
>>> single process with dlmopen(3) like linking for easy debugging.
>>
>> Is this the only difference?
>> We already have arch/um, why do you need arch/lib/ then?
>> My point is, can't you merge your arch/lib into the existing arch/um stuff?
>> From a very rough look your arch/lib seems like a micro UML.
> 
> I understand your point.
> but ptrace(2) based system call interception used by UML
> makes it depend on the host OS (i.e., linux kernel), while
> LibOS uses symbol hijacking with weak alias and LD_PRELOAD.
> 
> we're really thinking to run this library on other
> POSIX-like hosts (e.g., osx) though it's not coming yet.

Yeah, but this does not mean that arch/um and arch/lib can't coexist in arch/um.
Maybe you can add a "library operation mode" to UML.
I'll happily help you in that area.

>> BTW: There was already an idea for having UML as regular library.
>> See: http://user-mode-linux.sourceforge.net/old/projects.html
>> "UML as a normal userspace library"
> 
> thanks, it's new information for me.
> were there any trial on this idea ?

IIRC Jeff (the original author of UML) wanted to create a special linker script
such that you can build UML as shared object.

Thanks,
//richard
