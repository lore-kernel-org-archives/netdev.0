From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 net-next 4/6] bpf: Add support for reading socket
 family, type, protocol
Date: Thu, 1 Dec 2016 08:57:23 -0800
Message-ID: <20161201165722.GD46200@ast-mbp.thefacebook.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
 <1480610888-31082-5-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35700 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758179AbcLAQ5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:57:49 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so5132884pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:57:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480610888-31082-5-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 08:48:06AM -0800, David Ahern wrote:
> Add socket family, type and protocol to bpf_sock allowing bpf programs
> read-only access.
> 
> Add __sk_flags_offset[0] to struct sock before the bitfield to
> programmtically determine the offset of the unsigned int containing
> protocol and type.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
