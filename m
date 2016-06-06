From: Paul Moore <paul@paul-moore.com>
Subject: Re: [EDT][Patch 1/1] socket family check in netlabel APIs
Date: Mon, 6 Jun 2016 15:24:42 -0400
Message-ID: <CAHC9VhRMNfESJRN3e+FJV+JwzZn1Lcxc=gzfkBvy-h80jLOHrQ@mail.gmail.com>
References: <612771736.621921430978030389.JavaMail.weblogic@epmlwas01d>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Vaneet Narang <v.narang@samsung.com>,
	AJEET YADAV <ajeet.y@samsung.com>
To: maninder1.s@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <612771736.621921430978030389.JavaMail.weblogic@epmlwas01d>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 7, 2015 at 1:53 AM, Maninder Singh <maninder1.s@samsung.com> wrote:
> EP-E68D5E24548545C9BBB607A98ADD61E6
>
> Hi Paul,
>
>>On Monday, March 30, 2015 11:09:00 AM Maninder Singh wrote:
>>> Dear All,
>>> we found One Kernel Crash issue in cipso_v4_sock_delattr :-
>>> As Cipso supports only inet sockets so cipso_v4_sock_delattr will crash when
>>> try to access any other socket type.  cipso_v4_sock_delattr access
>>> sk_inet->inet_opt which may contain not NULL but invalid address. we found
>>> this issue with netlink socket.(reproducible by trinity using sendto system
>>> call .)
>
>>Hello,
>
>>First, please go read the Documentation/SubmittingPatches from the kernel
>>sources; your patch needs to be resubmitted and the instructions in that file
>>will show you how to do it correctly next time.
>
>>Second, this appears to only affect Smack based systems, yes?  SELinux based
>>systems should have the proper checking in place to prevent this (the checks
>>are handled in the LSM).  That said, it probably wouldn't hurt to add the
>>extra checking to netlbl_sock_delattr().  If you properly resubmit your patch
>>I'll ACK it.
>
>>-Paul
>
>>--
>>paul moore
>>www.paul-moore.com
>
> As suggested resubmitting the patch .

I was delayed in responding because your patch is still not in a form
that makes it easy to merge/review upstream, it appears to be MIME
encoded and not in plain text.  You should be able to save your raw
email message and apply it directly to the kernel source tree using
the patch command.

When you send MIME encoded emails with patches, we have to apply the
patches manually, line by line, which is both time consuming and error
prone.

-- 
paul moore
www.paul-moore.com
