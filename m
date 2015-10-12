From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next] f_bpf: allow for optional classid and
 add flags
Date: Mon, 12 Oct 2015 09:42:23 -0700
Message-ID: <20151012094223.620c02ce@urahara>
References: <efad6a0f1fc08df554d5b0d0b36fb3dde4afe131.1443176477.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36741 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbbJLQmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:42:11 -0400
Received: by pacex6 with SMTP id ex6so4323087pac.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 09:42:10 -0700 (PDT)
In-Reply-To: <efad6a0f1fc08df554d5b0d0b36fb3dde4afe131.1443176477.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Sep 2015 12:32:41 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> When having optional classid, most minimal command can be sth
> like:
> 
>   tc filter add dev foo parent X: bpf obj prog.o
> 
> Therefore, adapt the code so that a next argument will not be
> enforced as the case currently.
> 
> Also, minor cleanup on the classid, where we should rather
> have used addattr32(), and add flags for exec configuration,
> for example (using short notation):
> 
>   tc filter add dev foo parent X: bpf da obj prog.o
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to net-next branch of iproute2
