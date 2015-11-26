From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next v2 4/5] {f,m}_bpf: allow updates on program
 arrays
Date: Thu, 26 Nov 2015 16:51:55 +0100
Message-ID: <56572A9B.7080302@iogearbox.net>
References: <cover.1448547199.git.daniel@iogearbox.net> <552a9be16fb84dadc8333414d1b13a27622084d9.1448547199.git.daniel@iogearbox.net> <1448551169.889784.450810993.378A2FDF@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56735 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbbKZPwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 10:52:00 -0500
In-Reply-To: <1448551169.889784.450810993.378A2FDF@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2015 04:19 PM, Hannes Frederic Sowa wrote:
> On Thu, Nov 26, 2015, at 15:38, Daniel Borkmann wrote:
[...]
> Why does user space actually still have to deal with setting the mount
> point private? Isn't this handled by the kernel?
>
>> +       if (mount("bpf", target, "bpf", 0, NULL)) {
>> +               fprintf(stderr, "mount -t bpf bpf %s failed: %s\n",
>> +                       target, strerror(errno));
>> +               return -1;
>> +       }
>
> Shouldn't this be just enough?

Note that the patch just moves the function around, but to get to your
question, that would just make it shared by default, not private.

Thanks,
Daniel
