From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next v3 1/2] libbpf: parse maps sections of varying
 size
Date: Thu, 5 Oct 2017 19:52:34 +0200
Message-ID: <20171005195235.1fa3a8e4@redhat.com>
References: <20171005144158.14860-1-kraigatgoog@gmail.com>
        <20171005144158.14860-2-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org,
        brouer@redhat.com
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751335AbdJERwm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 13:52:42 -0400
In-Reply-To: <20171005144158.14860-2-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu,  5 Oct 2017 10:41:57 -0400 Craig Gallek <kraigatgoog@gmail.com> wrote:

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
> ---
>  tools/lib/bpf/libbpf.c | 70 +++++++++++++++++++++++++++++---------------------
>  1 file changed, 41 insertions(+), 29 deletions(-)

Thank you for working on this! :-)

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
