From: "Justin Mattock" <justinmattock@gmail.com>
Subject: Re: stuck tcp connections 2.6.26-rc7
Date: Mon, 23 Jun 2008 07:13:17 +0000
Message-ID: <dd18b0c30806230013x5446991bi9eba7623ffaae131@mail.gmail.com>
References: <dd18b0c30806221109t2ff73f9ai52f6716748648a79@mail.gmail.com>
	 <20080622205927.301501e7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:29959 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbYFWHNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 03:13:19 -0400
Received: by an-out-0708.google.com with SMTP id d40so558518and.103
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 00:13:18 -0700 (PDT)
In-Reply-To: <20080622205927.301501e7.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 3:59 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 22 Jun 2008 18:09:16 +0000 "Justin Mattock" <justinmattock@gmail.com> wrote:
>
>> Hello; I too am experiencing internet connectivity problems, for  a
>> while I thought
>> It was due to low bandwidth(or being ddos attacked) but yesterday I
>> noticed with watch netstat -ntu
>> send-Q was stuck on a number; the connection would not go to TIME_WAIT
>> resulting in music to pause, and t.v. to freeze.
>> In my experiences running xmms streaming music is fine, no problems,
>> but as soon as
>> you watch something with flash player the stream start's getting
>> really bad. In the past with older kernel's
>> I usually can watch t.v.(with flash) and stream music at the same time
>> without any trouble.
>> lately I've been Running the kernel in No forced Preemption with a
>> time frequency at 100. having the kernel set in this mode really shows
>> the connection problems, but if I change the preemption to another,
>> and bump up the timer frequency the poor internet connection is not as
>> bad(or stuck tcp) but still prevalent. more pops in the music, and
>> sudden internet loss for around five seconds, then goes back
>> So from over here streaming music has no problems from what I can see,
>> but as soon as I watch media, it becomes a mess.
>
> (cc netdev)
>


Cool, Thanks for sending the cc
regards;
-- 
Justin P. Mattock
