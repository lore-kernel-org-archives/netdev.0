From: "kalash nainwal" <nirvana.code@gmail.com>
Subject: Re: Is the TCP-code threaded?
Date: Sat, 24 Feb 2007 14:59:52 +0530
Message-ID: <e92e3a770702240129w14dc8f2oa4b3e99f423f4704@mail.gmail.com>
References: <45DF7B13.6040407@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: "Kristian Evensen" <kristrev@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:18451 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933453AbXBXJ3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 04:29:53 -0500
Received: by wx-out-0506.google.com with SMTP id h31so742914wxd
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 01:29:52 -0800 (PST)
In-Reply-To: <45DF7B13.6040407@ifi.uio.no>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/24/07, Kristian Evensen <kristrev@ifi.uio.no> wrote:
> Hello,
>
> I have been looking quite deeply into the TCP-code, but there is one
> thing I simply dont manage to understand. Can the code process more than
> one skb on a socket at the time, or is it strictly one and one?
>
> E.g say that you are going to send something (an skb), and you recieve
> an ack at the same time. Will the kernel finish whatever of the two
> comes first (say, finish sending) or can it, in the middle of treating
> the new packet to send, do a switch and process the ack?
>
send happes in process context, recv in interrupt context...isn't it?
