From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Slow tcp handshakes rate of 2.6.20 and 2.6.19
Date: Sat, 28 Apr 2007 06:43:00 +0200
Message-ID: <7e63f56c0704272143s677cdad8rcf64d1e97d88fc40@mail.gmail.com>
References: <e810d8480704271935l3a597d89g260bcb185c457937@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Quan Sun" <cfk.quan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:16365 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965426AbXD1EnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 00:43:02 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1178612muf
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 21:43:00 -0700 (PDT)
In-Reply-To: <e810d8480704271935l3a597d89g260bcb185c457937@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/28/07, Quan Sun <cfk.quan@gmail.com> wrote:
> Hi,
>   In these days I met a strange situation, tcp handshake rate is
> slow after 2.6.18.8.
>
>   The case is, server accepts connections, and records number of successful
> tcp handshakes during last 10 seconds. Client tries to connect to server's
> listen port as fast as possible and as many as possible, or in simple words,
> client use connect() to flood the server.  In both cases, there are a log of syn
> re-send.
>
>   Server's performances varied much, depending on which kernel it was
> running. On 2.6.18.8, 10000 successful connections take about 30-40 seconds,
> while on 2.6.20 or 2.6.19, it will cost about more than 5 minutes.

Please, look at this by pressing next_in_thread:
http://marc.info/?l=linux-netdev&m=117664202416020&w=2

What are the
#cat /proc/sys/net/ipv4/tcp_mem values for your kernels?

Do you see tcp memory pressure by
#netstat -s ?


Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://curl-loader.sourceforge.net
An open-source HTTP/S, FTP/S traffic
generating, and web testing tool.
