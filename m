From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Wed, 16 Apr 2014 10:32:40 +0200
Message-ID: <534E4028.6090501@redhat.com>
References: <1397585816-1267-1-git-send-email-chema@google.com> <CAMEtUuw3-LEuwJ2cAQ+F-tu_-wzy4HK4ZteAuJpYfY9hW66+FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chema Gonzalez <chema@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34910 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbaDPIcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2014 04:32:53 -0400
In-Reply-To: <CAMEtUuw3-LEuwJ2cAQ+F-tu_-wzy4HK4ZteAuJpYfY9hW66+FA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2014 08:24 AM, Alexei Starovoitov wrote:
...
> At the same time I think the extension technic itself is nice and clean :)
> The call approach is definitely how we envisioned it to be used.
> Right now we have only x86-64 jit that is waiting for net-next to be opened,
> but this extension will be automatically jit-ed due to 'call approach'. Nice.

Ok, in terms of JIT it's definitely better that way, agreed.
