From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc: fix compilation with old gcc (< 4.6)
Date: Thu, 07 Jan 2016 14:56:55 +0100
Message-ID: <568E6EA7.6080304@iogearbox.net>
References: <1452171793-5829-1-git-send-email-nicolas.dichtel@6wind.com> <568E68B2.2040102@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Julien Floret <julien.floret@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37279 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbcAGN45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 08:56:57 -0500
In-Reply-To: <568E68B2.2040102@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2016 02:31 PM, Daniel Borkmann wrote:
> On 01/07/2016 02:03 PM, Nicolas Dichtel wrote:
>> From: Julien Floret <julien.floret@6wind.com>
>>
>> gcc < 4.6 does not handle C11 syntax for the static initialization of
>> anonymous struct/union, hence the following error:
>>
>> tc_bpf.c:260: error: unknown field map_type specified in initializer
>>
>> Signed-off-by: Julien Floret <julien.floret@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Thanks!
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Btw, for iproute2's net-next branch there're couple of other occasions
as well. Stephen, how do you prefer to handle this? Should a separate
patch be done against net-next branch to reduce merge conflicts?
