From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Why return E2BIG from bpf map update?
Date: Tue, 21 Jul 2015 11:40:04 +0200
Message-ID: <55AE1374.6010608@iogearbox.net>
References: <CALCkm3eCUYFOon6Gza4A8Ske8MS1rVFJJip_J9dWQp79ju8zBw@mail.gmail.com> <55AD7514.7040906@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Gartrell <alexgartrell@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55433 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbbGUJkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 05:40:11 -0400
In-Reply-To: <55AD7514.7040906@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2015 12:24 AM, Alexei Starovoitov wrote:
> On 7/20/15 3:15 PM, Alex Gartrell wrote:
>> The ship has probably sailed on this one, but it seems like ENOSPC
>> makes more sense than E2BIG.  Any chance of changing it so that poor
>> ebpf library maintainers in the future don't have to wonder how their
>> argument list got too big?
>
> sorry, too late.
> It's in tests and even document in bpf manpage:
> "E2BIG - indicates that the number of elements in the map reached the
> max_entries limit specified at map creation time."
> I read E2BIG as "too big" and not as "argument list is too long" :)

If some libraries do an strerror(3) on errno then it certainly sounds
a bit weird, "no space left on device" perhaps also a bit misleading.
The bpf(2) manpage was actually submitted/discussed longer time ago,
but I still didn't see it in Michael's tree yet, will ping him again.
