From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: Why return E2BIG from bpf map update?
Date: Tue, 21 Jul 2015 14:34:39 -0700
Message-ID: <55AEBAEF.8090707@plumgrid.com>
References: <CALCkm3eCUYFOon6Gza4A8Ske8MS1rVFJJip_J9dWQp79ju8zBw@mail.gmail.com>
 <55AD7514.7040906@plumgrid.com> <55AE1374.6010608@iogearbox.net>
 <CALCkm3ck95Py=vPq+fWrcps=EVwtgFhDvGGyfoZ0AkLraaZJNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alex Gartrell <alexgartrell@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36346 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbbGUVel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 17:34:41 -0400
Received: by qkdv3 with SMTP id v3so142059228qkd.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 14:34:40 -0700 (PDT)
In-Reply-To: <CALCkm3ck95Py=vPq+fWrcps=EVwtgFhDvGGyfoZ0AkLraaZJNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/15 3:13 AM, Alex Gartrell wrote:
> But, the EINVAL errno has similarly been
> abused to death

there was a thread few month ago trying to come up with
a generic solution for aliased error codes, but unfortunately
nothing concrete came out of it.
The one I liked sounded that the kernel may be able to extend
syscall interface to return a string together with errno,
but it's quite hard to do at present.
May be extensions to vdso data writable by kernel can
improve the situation.
