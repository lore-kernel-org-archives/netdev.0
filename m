From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: Re: [Lksctp-developers] Re: [PATCH] subset of RFC2553
Date: Thu, 20 Feb 2003 15:24:01 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E554771.5020104@us.ibm.com>
References: <1045621941.1253.21.camel@w-bwa1.beaverton.ibm.com> <3E54128C.327D7759@us.ibm.com> <3E541FEA.C34BEEB7@us.ibm.com> <3E542F52.50001@us.ibm.com> <3E554063.3010008@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bruce Allan <bwa@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Bruce Allan wrote:

> 
> #define _SS_MAXSIZE  128  /* Implementation specific max size */
> struct sockaddr_storage {
>        sa_family_t      ss_family;
>        char                 __data[_SS_MAXSIZE - sizeof(sa_family_t)];
> } __attribute __ ((aligned(sizeof(struct sockaddr *))));
> 

This works for me.  I really just needed the struct to come out to 128 
bytes.

> The use of the 'sizeof(struct sockaddr *)' for specifying the required 
> alignment is just to illustrate the second criteria for this structure 
> as documented in the RFC, i.e. "It is aligned at an appropriate boundary 
> so protocol specific socket address data structure pointers can be cast 
> to it and access their fields without alignment problems...".
> 

Yes.  I agree.

> I'll resubmit a patch tomorrow with the above definition if there are no 
> objections.
> 

OK.  I compiled this on 4 and 8 byte alignements.

jon
