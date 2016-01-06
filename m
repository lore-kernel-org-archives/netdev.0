From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: cleanup bpf_prog_run_{save,clear}_cb
 helpers
Date: Wed, 6 Jan 2016 14:13:53 -0800
Message-ID: <20160106221352.GB95332@ast-mbp.thefacebook.com>
References: <aaa1eb34322115d06f15946989f4ebd3e399a56e.1452115518.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33682 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbcAFWN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 17:13:58 -0500
Received: by mail-pa0-f54.google.com with SMTP id cy9so241233801pac.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 14:13:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <aaa1eb34322115d06f15946989f4ebd3e399a56e.1452115518.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2016 at 10:32:16PM +0100, Daniel Borkmann wrote:
> Move the details behind the cb[] access into a small helper to decouple
> and make them generic for bpf_prog_run_save_cb()/bpf_prog_run_clear_cb()
> that was introduced via commit ff936a04e5f2 ("bpf: fix cb access in socket
> filter programs"). Also add a comment to better clarify what is done in
> bpf_skb_cb().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks. Great catch.
Acked-by: Alexei Starovoitov <ast@kernel.org>
