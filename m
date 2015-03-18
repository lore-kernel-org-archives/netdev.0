From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc: m_bpf: fix next arg selection after tc opcode
Date: Wed, 18 Mar 2015 11:02:54 +0100
Message-ID: <55094D4E.4070101@iogearbox.net>
References: <1af5314868a14e738b049319dc2c21102134bc9b.1426669396.git.daniel@iogearbox.net> <20150318100023.GC1992@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42466 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118AbbCRKC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:02:58 -0400
In-Reply-To: <20150318100023.GC1992@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2015 11:00 AM, Jiri Pirko wrote:
> Wed, Mar 18, 2015 at 10:13:34AM CET, daniel@iogearbox.net wrote:
>> Next argument after the tc opcode/verdict is optional, using NEXT_ARG()
>> requires to have another argument after that one otherwise tc will bail
>> out. Therefore, we need to advance to the next argument manually as done
>> elsewhere.
>>
>> Fixes: 86ab59a6660f ("tc: add support for BPF based actions")
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Thanks for fixing this Daniel.

Thanks & sorry I forgot to put you in Cc, I realized that too late.

Lack of coffee. ;)
