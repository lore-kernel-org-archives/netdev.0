From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] bpf: fix state equivalence
Date: Wed, 7 Dec 2016 20:47:07 +0100
Message-ID: <20161207194707.GA22108@pox.localdomain>
References: <1481137079-2205635-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Josef Bacik <jbacik@fb.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f178.google.com ([209.85.210.178]:36577 "EHLO
        mail-wj0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752524AbcLGTrK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 14:47:10 -0500
Received: by mail-wj0-f178.google.com with SMTP id tk12so75891835wjb.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 11:47:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481137079-2205635-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/16 at 10:57am, Alexei Starovoitov wrote:
> Commmits 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
> and 484611357c19 ("bpf: allow access into map value arrays") by themselves
> are correct, but in combination they make state equivalence ignore 'id' field
> of the register state which can lead to accepting invalid program.
> 
> Fixes: 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
> Fixes: 484611357c19 ("bpf: allow access into map value arrays")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Thomas Graf <tgraf@suug.ch>
