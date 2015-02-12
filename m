From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 6/7] ebpf: remove CONFIG_BPF_SYSCALL ifdefs in
 socket filter code
Date: Thu, 12 Feb 2015 21:09:46 +0100
Message-ID: <54DD088A.7020106@iogearbox.net>
References: <CAMEtUuzruMSO7zwhYLfVdO0=YN_dJ+pLAoEg_pCVT8FT=DRz_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38705 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbbBLUKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 15:10:50 -0500
In-Reply-To: <CAMEtUuzruMSO7zwhYLfVdO0=YN_dJ+pLAoEg_pCVT8FT=DRz_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2015 02:51 AM, Alexei Starovoitov wrote:
...
> why move the functions inside filter.c ?
> couldn't we just remove two lines with #ifdef/endif ?

Yep, will do in the non-RFC. That should make it shorter.
