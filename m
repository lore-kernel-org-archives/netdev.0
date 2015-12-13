From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, inode: allow for rename and link ops
Date: Sat, 12 Dec 2015 19:06:15 -0500 (EST)
Message-ID: <20151212.190615.2226584145922779613.davem@davemloft.net>
References: <023d613fa37780f354c130c7920a43da2090e58e.1449782627.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbbLMAVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 19:21:19 -0500
In-Reply-To: <023d613fa37780f354c130c7920a43da2090e58e.1449782627.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 10 Dec 2015 22:33:49 +0100

> Add support for renaming and hard links to the fs. Most of this can be
> implemented by using simple library operations under the same constraints
> that we don't use a reserved name like elsewhere. Linking can be useful
> to share/manage things like maps across subsystem users. It works within
> the file system boundary, but is not allowed for directories.
> 
> Symbolic links are explicitly not implemented here, as it can be better
> done already by doing bind mounts inside bpf fs to set up shared directories
> f.e. useful when using volumes in docker containers that map a private
> working directory into /sys/fs/bpf/ which contains itself a bind mounted
> path from the host's /sys/fs/bpf/ mount that is shared among multiple
> containers. For single maps instead of whole directory, hard links can
> be easily used to do the same.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
