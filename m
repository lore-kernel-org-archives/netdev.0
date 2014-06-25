From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 16/17] MIPS: bpf: Use 32 or 64-bit load instruction to
 load an address to register
Date: Wed, 25 Jun 2014 07:28:39 -0700
Message-ID: <CAMEtUuwzsWX=JR8PJo=MnX_KG8ActhDPju26wOO-9GUZPg_pwA@mail.gmail.com>
References: <53AA85E8.5090403@imgtec.com>
	<1403685578-25170-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux MIPS Mailing List <linux-mips@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:56861 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757066AbaFYO2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 10:28:43 -0400
Received: by mail-wg0-f47.google.com with SMTP id k14so2168507wgh.30
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 07:28:40 -0700 (PDT)
In-Reply-To: <1403685578-25170-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 1:39 AM, Markos Chandras
<markos.chandras@imgtec.com> wrote:
> When loading a pointer to register we need to use the appropriate
> 32 or 64bit instruction to preserve the pointers' top 32bits.
>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
> ---
> Changes since v1:
> - Change function name to make it clear that we are loading a
> pointer to a register, not an address

Markos,

when you post v2, please refresh the whole series, add v2 to subject and repost
all patches from scratch.

Thanks
