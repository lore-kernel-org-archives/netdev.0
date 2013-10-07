From: Steve Rago <sar@nec-labs.com>
Subject: Re: bug in passing file descriptors
Date: Mon, 7 Oct 2013 16:29:15 -0400
Message-ID: <5253199B.3000109@nec-labs.com>
References: <5253061A.7060701@nec-labs.com> <20131007.151233.2237348893254566536.davem@davemloft.net> <525308C4.1030007@nec-labs.com> <20131007.154226.533738557474978526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <luto@amacapital.net>, <netdev@vger.kernel.org>,
	<mtk.manpages@gmail.com>, <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nec-labs.com ([138.15.200.209]:54370 "EHLO
	mail.nec-labs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab3JGU3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 16:29:20 -0400
In-Reply-To: <20131007.154226.533738557474978526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2013 03:42 PM, David Miller wrote:
> There is no compatability issue.
>
> 32-bit tasks will always see the 4-byte align/length.
> 64-bit tasks will always see the 8-byte align/length.
>

Really?  So when I compile my application on a 32-bit Linux box and then try to run it on a 64-bit Linux box, you're not 
going to overrun my buffer when CMSG_SPACE led me to allocate an insufficient amount of memory needed to account for 
padding on the 64-bit platform?

By the way, FreeBSD, Mac OS X, and Solaris all behave as I described, so if you're happy with Linux behaving 
differently, then I'll stop wasting bandwidth.

Steve
