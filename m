From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: Why return E2BIG from bpf map update?
Date: Mon, 20 Jul 2015 15:24:20 -0700
Message-ID: <55AD7514.7040906@plumgrid.com>
References: <CALCkm3eCUYFOon6Gza4A8Ske8MS1rVFJJip_J9dWQp79ju8zBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alex Gartrell <alexgartrell@gmail.com>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:33021 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757094AbbGTWYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 18:24:22 -0400
Received: by ykfw194 with SMTP id w194so70464989ykf.0
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 15:24:21 -0700 (PDT)
In-Reply-To: <CALCkm3eCUYFOon6Gza4A8Ske8MS1rVFJJip_J9dWQp79ju8zBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/20/15 3:15 PM, Alex Gartrell wrote:
> The ship has probably sailed on this one, but it seems like ENOSPC
> makes more sense than E2BIG.  Any chance of changing it so that poor
> ebpf library maintainers in the future don't have to wonder how their
> argument list got too big?

sorry, too late.
It's in tests and even document in bpf manpage:
"E2BIG - indicates that the number of elements in the map reached the
max_entries limit specified at map creation time."
I read E2BIG as "too big" and not as "argument list is too long" :)
