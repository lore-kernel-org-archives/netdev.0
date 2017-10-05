From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 1/2] libbpf: parse maps sections of varying
 size
Date: Thu, 05 Oct 2017 21:25:49 +0200
Message-ID: <59D6873D.6070407@iogearbox.net>
References: <20171005144158.14860-1-kraigatgoog@gmail.com> <20171005144158.14860-2-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36685 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751459AbdJETZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 15:25:56 -0400
In-Reply-To: <20171005144158.14860-2-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2017 04:41 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> This library previously assumed a fixed-size map options structure.
> Any new options were ignored.  In order to allow the options structure
> to grow and to support parsing older programs, this patch updates
> the maps section parsing to handle varying sizes.
>
> Object files with maps sections smaller than expected will have the new
> fields initialized to zero.  Object files which have larger than expected
> maps sections will be rejected unless all of the unrecognized data is zero.
>
> This change still assumes that each map definition in the maps section
> is the same size.
>
> Signed-off-by: Craig Gallek <kraig@google.com>

Thanks,

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
