From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: linux-next: manual merge of the sysctl tree with the net tree
Date: Fri, 04 Dec 2009 00:50:04 -0800
Message-ID: <m1ocmfdsxv.fsf@fess.ebiederm.org>
References: <20091204193613.8986a3c6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091204193613.8986a3c6.sfr@canb.auug.org.au> (Stephen Rothwell's message of "Fri\, 4 Dec 2009 19\:36\:13 +1100")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Hi Eric,
>
> Today's linux-next merge of the sysctl tree got a conflict in
> kernel/sysctl_check.c between commit
> 8153a10c08f1312af563bb92532002e46d3f504a ("ipv4: add sysctl to accept
> packets with local source addresses") from the net tree and commit
> 83ac201b4f06eb8aeb7ac93cf162651ba30e0b28 ("sysctl: Remove dead code from
> sysctl_check") from the sysctl tree.
>
> The latter removes the need for the former to change this file.  I just
> used the latter.

Rats.  I feel blind.  I totally missed the fact that sysctl_check was
changed in that one.

Eric
