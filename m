From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: inherit auth_capable on INIT collisions
Date: Tue, 22 Jul 2014 18:43:16 +0200
Message-ID: <53CE94A4.1050800@redhat.com>
References: <1405620319-2021-1-git-send-email-dborkman@redhat.com> <53C93157.1050002@gmail.com> <53C972BE.5090700@redhat.com> <53C998DE.2030805@gmail.com> <53CE6632.1060707@redhat.com> <53CE9428.9060809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgunthorpe@obsidianresearch.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57443 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755013AbaGVQn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 12:43:29 -0400
In-Reply-To: <53CE9428.9060809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 06:41 PM, Vlad Yasevich wrote:
> On 07/22/2014 09:25 AM, Daniel Borkmann wrote:
>> Hi Vlad,
>>
>> On 07/18/2014 11:59 PM, Vlad Yasevich wrote:
>> ...
>>> So I think I know why case D ends up not authenticating the COOKIE-ACK.
>>> Most likely the reason is the following statement:
>>>    repl = sctp_make_cookie_ack(new_asoc, chunk);
>>>
>>> Note that we use new_asoc, instead of current asoc.
>>
>> Are you sending out a patch for this?
>
> I didn't plan on it since you said there are further issues.  I thought you
> were still looking.

Ok, understood. Yeah, I'm looking further for the other cases
as well.
