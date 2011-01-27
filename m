From: Tom Herbert <therbert@google.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Thu, 27 Jan 2011 13:32:25 -0800
Message-ID: <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:2989 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab1A0Vc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 16:32:29 -0500
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p0RLWSqI008411
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 13:32:28 -0800
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by wpaz1.hot.corp.google.com with ESMTP id p0RLWQgp010779
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 13:32:27 -0800
Received: by pwj5 with SMTP id 5so647088pwj.29
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 13:32:26 -0800 (PST)
In-Reply-To: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 2:07 AM, Daniel Baluta <daniel.baluta@gmail.com> wrote:
> Hi Tom,
>
> How did you solved the issue regarding scaling TCP listeners?
> I think SO_REUSEPORT proposed by patch [1] can be a good
> start. Where there any follow ups?
>

As Bill mentioned we are continue to work on the TCP issues.  Looks
like modifying the TCP listener structures will probably be required.

> Also, solving the problem in users pace can be an option. I want
> to run multiple instances of a DNS server on a multi core system.
> Any suggestions would be welcomed.
>
> SO_REUSEPORT option seems to be already there [2]. Where
> there any plans to have a kernel implementation?
>

Yes, we are still planning this.  The UDP implementation for my
earlier patch should be usable to try for DNS/UDP-- this is in fact
where we saw a major performance gain.  Eric Dumazet had some nice
improvements that should probably be looked at also.

Tom
