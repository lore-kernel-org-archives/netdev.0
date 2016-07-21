From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/3] net/mlx4_en: use READ_ONCE when freeing
 xdp_prog
Date: Wed, 20 Jul 2016 18:20:37 -0700
Message-ID: <20160721012036.GB86045@ast-mbp.thefacebook.com>
References: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
 <1469060555-20250-2-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34457 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbcGUBUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 21:20:41 -0400
Received: by mail-yw0-f171.google.com with SMTP id z8so39612676ywa.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 18:20:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469060555-20250-2-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 05:22:33PM -0700, Brenden Blanco wrote:
> For consistency, and in order to hint at the synchronous nature of the
> xdp_prog field, use READ_ONCE in the destroy path of the ring. All
> occurrences should now use either READ_ONCE or xchg.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
