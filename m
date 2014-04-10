From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH v2 13/14] MIPS: net: Add BPF JIT
Date: Thu, 10 Apr 2014 08:46:26 +0100
Message-ID: <53464C52.2060004@imgtec.com>
References: <1396957635-27071-14-git-send-email-markos.chandras@imgtec.com> <1397059208-27096-1-git-send-email-markos.chandras@imgtec.com> <CAOiHx=kh3+Xzvyx7PsEfNCiEf6cRP3ucQKDfY3brZ6FR2KwW4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: MIPS Mailing List <linux-mips@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jonas Gorski <jogo@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.89.28.114]:41337 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934648AbaDJHqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 03:46:11 -0400
In-Reply-To: <CAOiHx=kh3+Xzvyx7PsEfNCiEf6cRP3ucQKDfY3brZ6FR2KwW4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2014 11:28 PM, Jonas Gorski wrote:
>
>> +#ifdef CONFIG_CPU_LITTLE_ENDIAN
>> +                       /* This needs little endian fixup */
>> +                       if (config_enabled(CPU_MIPSR1)) {
>
> Hm, looking at arch/mips/Kconfig, this will falsely identify CPU_BMIPS
> as R2 as it does not select CPU_MIPSR1.
>
> How about "if (cpu_has_mips_r1)"? There are some targets that have
> both R1 and R2 cores (e.g. bcm47xx), and even if we built the kernel
> for R1, it does not prevent us from emitting R2 instructions because
> we do this at runtime when we can check for it.

Sounds about right. Let me have a look


-- 
markos
