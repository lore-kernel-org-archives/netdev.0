From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 51/51] lib/bpf: Check return value of write()
Date: Tue, 15 Aug 2017 15:00:22 +0200
Message-ID: <5992F066.10201@iogearbox.net>
References: <20170812120510.28750-1-phil@nwl.cc> <20170812120510.28750-52-phil@nwl.cc> <063D6719AE5E284EB5DD2968C1650D6DD0055BA8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40101 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdHONAi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:00:38 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0055BA8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2017 02:31 PM, David Laight wrote:
[...]
> WTF is this code doing anyway?
> write() is a system call, fflush() writes out any data buffered in the
> stdio stream.
> If there was anything buffered you'd want to output it earlier.
> Otherwise if it is going to use fflush() it should be using fwrite().
>
> I presume the function is allowed to write to stderr - since in general
> library functions shouldn't assume fd 0/1/2 or stdin/out/err are valid.
> There is a lot of code out there that does close(0); close(1); close(2);
> but leaves stdout/err valid. Call printf() instead of sprint() and eventually
> 10k of data gets written somewhere rather unexpected.
>
> If it is a copy loop, what is wrong with the last byte of buff[].
> It is valid for write() to return a partial length - the code should
> probably loop until all the data is accepted (or error).

Just send a patch if you really care; would have probably been faster
than typing up your email. ;) Thank you!
