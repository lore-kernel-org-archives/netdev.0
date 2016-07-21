From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/3] rtnl: protect do_setlink from
 IFLA_XDP_ATTACHED
Date: Wed, 20 Jul 2016 18:21:52 -0700
Message-ID: <20160721012152.GC86045@ast-mbp.thefacebook.com>
References: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
 <1469060555-20250-3-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34163 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbcGUBV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 21:21:56 -0400
Received: by mail-yw0-f194.google.com with SMTP id j12so4046152ywb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 18:21:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469060555-20250-3-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 05:22:34PM -0700, Brenden Blanco wrote:
> The IFLA_XDP_ATTACHED nested attribute is meant for read-only, and while
> do_setlink properly ignores it, it should be more paranoid and reject
> commands that try to set it.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
