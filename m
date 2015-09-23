From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/3] cls_bpf: make binding to classid optional
Date: Wed, 23 Sep 2015 13:53:29 -0700
Message-ID: <56031149.50003@plumgrid.com>
References: <cover.1443037353.git.daniel@iogearbox.net>
 <564eafb6e648e41ad57f5d36139d667745478366.1443037353.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35656 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbbIWUxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 16:53:30 -0400
Received: by pacfv12 with SMTP id fv12so51157289pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 13:53:30 -0700 (PDT)
In-Reply-To: <564eafb6e648e41ad57f5d36139d667745478366.1443037353.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 12:56 PM, Daniel Borkmann wrote:
> The binding to a particular classid was so far always mandatory for
> cls_bpf, but it doesn't need to be. Therefore, lift this restriction
> as similarly done in other classifiers.
>
> Only a couple of qdiscs make use of class from the tcf_result, others
> don't strictly care, so let the user choose his needs (those that read
> out class can handle situations where it could be NULL).
>
> An explicit check for tcf_unbind_filter() is also not needed here, as
> the previous r->class was 0, so the xchg() will return that and
> therefore a callback to the qdisc's unbind_tcf() is skipped.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
