From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 net-next 3/4] soreuseport: setsockopt
 SO_ATTACH_REUSEPORT_[CE]BPF
Date: Mon, 4 Jan 2016 14:53:49 -0800
Message-ID: <20160104225348.GA34405@ast-mbp.thefacebook.com>
References: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
 <1451947308-7867-4-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35091 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbcADWxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:53:41 -0500
Received: by mail-pa0-f53.google.com with SMTP id do7so3311624pab.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:53:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1451947308-7867-4-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2016 at 05:41:47PM -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Expose socket options for setting a classic or extended BPF program
> for use when selecting sockets in an SO_REUSEPORT group.  These options
> can be used on the first socket to belong to a group before bind or
> on any socket in the group after bind.
> 
> This change includes refactoring of the existing sk_filter code to
> allow reuse of the existing BPF filter validation checks.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

looks good to me. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
