From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 14:12:41 -0700
Message-ID: <448F2A49.5020809@google.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <20060613140716.6af45bec@localhost.localdomain> <20060613052215.B27858@openss7.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:7539 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP id S932253AbWFMVNF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 17:13:05 -0400
To: bidulock@openss7.org
In-Reply-To: <20060613052215.B27858@openss7.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian F. G. Bidulock wrote:
> Stephen,
> 
> On Tue, 13 Jun 2006, Stephen Hemminger wrote:
> 
> 
>>>@@ -2176,3 +2279,13 @@ EXPORT_SYMBOL(sock_wake_async);
>>> EXPORT_SYMBOL(sockfd_lookup);
>>> EXPORT_SYMBOL(kernel_sendmsg);
>>> EXPORT_SYMBOL(kernel_recvmsg);
>>>+EXPORT_SYMBOL(kernel_bind);
>>>+EXPORT_SYMBOL(kernel_listen);
>>>+EXPORT_SYMBOL(kernel_accept);
>>>+EXPORT_SYMBOL(kernel_connect);
>>>+EXPORT_SYMBOL(kernel_getsockname);
>>>+EXPORT_SYMBOL(kernel_getpeername);
>>>+EXPORT_SYMBOL(kernel_getsockopt);
>>>+EXPORT_SYMBOL(kernel_setsockopt);
>>>+EXPORT_SYMBOL(kernel_sendpage);
>>>+EXPORT_SYMBOL(kernel_ioctl);
>>
>>Don't we want to restrict this to GPL code with EXPORT_SYMBOL_GPL?
> 
> 
> There are direct derivatives of the BSD/POSIX system call
> interface.  The protocol function pointers within the socket
> structure are not GPL only.  Why make this wrappered access to
> them GPL only?  It will only encourange the reverse of what they
> were intended to do: be used instead of the protocol function
> pointers within the socket structure, that currently carry no
> such restriction.

This has the makings of a nice stable internal kernel api.  Why do we want
to provide this nice stable internal api to proprietary modules?

Regards,

Daniel
