From: "Carlos O'Donell" <carlos@redhat.com>
Subject: Re: [GLIBC Patch v2] inet: avoid redefinition of some structs in
 kernel
Date: Fri, 06 Sep 2013 00:52:01 -0400
Message-ID: <52295F71.50401@redhat.com>
References: <1376558891-26221-1-git-send-email-amwang@redhat.com> <1376558891-26221-2-git-send-email-amwang@redhat.com> <201308260126.06626.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: libc-alpha@sourceware.org, Cong Wang <amwang@redhat.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Thomas Backlund <tmb@mageia.org>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <libc-alpha-return-42562-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-##L=##H@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <201308260126.06626.vapier@gentoo.org>
List-Id: netdev.vger.kernel.org

On 08/26/2013 01:26 AM, Mike Frysinger wrote:
> On Thursday 15 August 2013 05:28:11 Cong Wang wrote:
>> From: Carlos O'Donell <carlos@redhat.com>
>>
>> - Synchronize linux's `include/uapi/linux/in6.h'
>>   with glibc's `inet/netinet/in.h'.
>> - Synchronize glibc's `inet/netinet/in.h with linux's
>>   `include/uapi/linux/in6.h'.
>> - Allow including the headers in either other.
>> - First header included defines the structures and macros.
>>
>> Notes:
>> - You want netinet/in.h to include bits/in.h as early as possible,
>>   but it needs in_addr so define in_addr early.
>> - You want bits/in.h included as early as possible so you can use
>>   the linux specific code to define __USE_KERNEL_DEFS based on
>>   the _UAPI_* macro definition and use those to cull in.h.
>> - glibc was missing IPPROTO_MH, added here.
> 
> can we get something better documented here in a central location ?  having 
> the names laid out in a git commit message and in a few leaf headers does not 
> lend itself to being easily discoverable.

Care to suggest something?

Cheers,
Carlos.
