From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] filter: added BPF random opcode
Date: Tue, 22 Apr 2014 23:10:44 +0200
Message-ID: <5356DAD4.8090100@redhat.com>
References: <1397585816-1267-1-git-send-email-chema@google.com> <1398097284-20528-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3127 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755073AbaDVVKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 17:10:52 -0400
In-Reply-To: <1398097284-20528-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2014 06:21 PM, Chema Gonzalez wrote:
> Added a new ancillary load (bpf call in eBPF parlance) that produces
> a 32-bit random number. We are implementing it as an ancillary load
> (instead of an ISA opcode) because (a) it is simpler, (b) allows easy
> JITing, and (c) seems more in line with generic ISAs that do not have
> "get a random number" as a instruction, but as an OS call.
>
> The main use for this ancillary load is to perform random packet sampling.
>
> Signed-off-by: Chema Gonzalez <chema@google.com>

Generally, I'm fine with your patch. If some day other use cases pop up
in non-packet filtering areas, we might need to let it return a 64 bit
number, but lets see. Thanks again for updating bpf_asm as well!

Acked-by: Daniel Borkmann <dborkman@redhat.com>
