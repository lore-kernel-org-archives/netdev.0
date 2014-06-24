From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: filter: Use kcalloc/kmalloc_array to allocate arrays
Date: Tue, 24 Jun 2014 15:47:24 +0200
Message-ID: <53A9816C.30903@redhat.com>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch> <1403616802-25743-3-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbaFXNrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 09:47:36 -0400
In-Reply-To: <1403616802-25743-3-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2014 03:33 PM, Tobias Klauser wrote:
> Use kcalloc/kmalloc_array to make it clear we're allocating arrays. No
> integer overflow can actually happen here, since len/flen is guaranteed
> to be less than BPF_MAXINSNS (4096). However, this changed makes sure
> we're not going to get one if BPF_MAXINSNS were ever increased.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
