From: "Carlos O'Donell" <carlos@redhat.com>
Subject: Re: [GLIBC Patch v2] inet: avoid redefinition of some structs in
 kernel
Date: Mon, 19 Aug 2013 14:11:09 -0400
Message-ID: <52125FBD.7020905@redhat.com>
References: <1376558891-26221-1-git-send-email-amwang@redhat.com>  <1376558891-26221-2-git-send-email-amwang@redhat.com>  <520E4995.5090101@redhat.com> <1376875250.2742.2.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Thomas Backlund <tmb@mageia.org>, libc-alpha@sourceware.org,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <libc-alpha-return-42043-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-##L=##H@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <1376875250.2742.2.camel@cr0>
List-Id: netdev.vger.kernel.org

On 08/18/2013 09:20 PM, Cong Wang wrote:
> On Fri, 2013-08-16 at 11:47 -0400, Carlos O'Donell wrote:
>> On 08/15/2013 05:28 AM, Cong Wang wrote:
>>> 2013-08-13  Carlos O'Donell  <carlos@redhat.com>
>>> 	    Cong Wang <amwang@redhat.com>
>>>
>>> 	* sysdeps/unix/sysv/linux/bits/in.h
>>> 	[_UAPI_LINUX_IN6_H]: Define __USE_KERNEL_IPV6_DEFS.
>>> 	* inet/netinet/in.h: Move in_addr definition and bits/in.h inclusion
>>> 	before __USE_KERNEL_IPV6_DEFS uses.
>>> 	* inet/netinet/in.h [!__USE_KERNEL_IPV6_DEFS]: Define IPPROTO_MH, and
>>> 	IPPROTO_BEETPH.
>>> 	[__USE_KERNEL_IPV6_DEFS]: Don't define any of IPPROTO_*, in6_addr,
>>> 	sockaddr_in6, or ipv6_mreq.
>>
>> Cong,
>>
>> Given that this is a user visible change could you please file
>> a glibc bugzilla bug in sourceware[1] so we can track the commit and so
>> that future users can reopen the bug to discuss any defects?
> 
> Done, http://sourceware.org/bugzilla/show_bug.cgi?id=15850
 
Perfect.
 
>>
>> Then you need to add the BZ# to the ChangeLog, and whomever
>> commits this for you will mark it fixed in the NEWS. We should
>> also write up a NEWS blurb for this since it's the first explicit
>> header coordination of it's kind and we should highlight that
>> so developers take note and help us coordinate more headers.
>>
> 
> Should I resend this patch with BZ# included?

No need. But the final ChangeLog should have the BZ# in it, and the
committer will add it to the NEWS list of bugs fixed in 2.19.

Cheers,
Carlos.
