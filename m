From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: Could I export the udp socket security contexts to /proc/net/udp
Date: Wed, 3 Aug 2011 16:07:46 +0800
Message-ID: <4E3901D2.7090907@windriver.com>
References: <4E30F5EB.60606@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34620 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab1HCIHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 04:07:46 -0400
In-Reply-To: <4E30F5EB.60606@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David:

Could you give some comments to my thought?

Thanks very much

Br


On 07/28/2011 01:38 PM, Rongqing Li wrote:
> Hi Linux-netdev folks:
>
> Could I export the socket security contexts to udp, tcp, raw,
> unix file under /proc/net/?
>
>
> If can not, Could you tell me where and how I should export this
> information to?
>
>
> The element sk_security of struct sock represents the socket
> security context ID, which is inheriting from the process which
> creates this socket most of the time.
>
>
> but when SELinux type_transition rule is applied to socket, or
> application sets /proc/xxx/attr/createsock, the socket security
> context would be different from the creating process. on this
> condition, the "netstat -Z" will return wrong value, since
> "netstat -Z" only returns the process security context as socket
> process security.
>
>
> I want to fix "netstat -Z", but first the kernel must export this
> information, like /proc/xxx/attr/current is the process security
> context. So I have this requirement.
>
>
> Expect your instruction.
>
> Thanks.
>

-- 
Best Reagrds,
Roy | RongQing Li
-------------------------------------------------------------
WIND RIVER Beijing | China Development Center
Phone: +86-10-6483-5025, Cell: +86-135-2202-9864, Fax: +86-10-6479-0367
