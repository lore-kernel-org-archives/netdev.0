From: "kalash nainwal" <nirvana.code@gmail.com>
Subject: Re: Copy data from one SKB to another
Date: Sat, 24 Feb 2007 15:07:40 +0530
Message-ID: <e92e3a770702240137p6c0b31b3r2b7ce0b4042fac4b@mail.gmail.com>
References: <58989.129.240.228.53.1172145587.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: "kristrev@student.matnat.uio.no" <kristrev@student.matnat.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:21818 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933458AbXBXJhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 04:37:40 -0500
Received: by wx-out-0506.google.com with SMTP id h31so744440wxd
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 01:37:40 -0800 (PST)
In-Reply-To: <58989.129.240.228.53.1172145587.squirrel@webmail.uio.no>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/07, kristrev@student.matnat.uio.no
<kristrev@student.matnat.uio.no> wrote:
> Hello,
>
> I am working on optimizing the TCP-code for a certain type of TCP-stream,
> and to make one of my optimizations work I need to copy data from one SKB
> (the data field of the skb) to another SKB (data field).
>
> Currently I am using memcpy, and it does what it is supposed to, but I am
> curious as to if there are any other (potentially faster/more efficient)
> ways of doing it. I have checked out the skb_add_data (used when you can
> copy data from the msg you are sending into the most recent skb added to
> the queue), but from what I can understand it only copies from userspace
> into kernelspace (whereas I need to copy kernel-kernel).
>
> Does anyone have any hints, suggestions, solutions or something else they
> think might help?
>
> Thanks,
> Kristian
>
> -

How about cloning? Is that an option?
