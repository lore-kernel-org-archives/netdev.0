From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Sat, 02 Apr 2016 20:40:55 +0200
Message-ID: <1459622455.18188.5.camel@sipsolutions.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
	 (sfid-20160402_032226_544590_102A25B3)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58723 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219AbcDBSlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2016 14:41:01 -0400
In-Reply-To: <1459560118-5582-5-git-send-email-bblanco@plumgrid.com> (sfid-20160402_032226_544590_102A25B3)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 18:21 -0700, Brenden Blanco wrote:

> +static int mlx4_bpf_set(struct net_device *dev, int fd)
> +{
[...]
> +		if (prog->type != BPF_PROG_TYPE_PHYS_DEV) {
> +			bpf_prog_put(prog);
> +			return -EINVAL;
> +		}
> +	}

Why wouldn't this check be done in the generic code that calls
ndo_bpf_set()?

johannes
