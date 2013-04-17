From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 12/14] netlink: add documentation for memory mapped I/O
Date: Wed, 17 Apr 2013 19:51:09 +0200
Message-ID: <516EE10D.2080608@redhat.com>
References: <1366217229-22705-1-git-send-email-kaber@trash.net> <1366217229-22705-13-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366217229-22705-13-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/17/2013 06:47 PM, Patrick McHardy wrote:
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---
[...]
> +Ring frames
> +------------
> +
> +Each frames contain a frame header, consisting of a synchronization word and some
> +meta-data, and the message itself.
> +
> +Frame:	[ header message ]
> +
> +The frame header is defined as follows:
> +
> +struct nl_mmap_hdr {
> +	unsigned int	nm_status;
> +	unsigned int	nm_len;
> +	__u32		nm_group;
> +	/* credentials */
> +	__u32		nm_pid;
> +	__u32		nm_uid;
> +	__u32		nm_gid;
> +};

Hm, just wondering, maybe it could be a safer path to make 'nm_status'
and 'nm_len' also of fixed width as the rest of nl_mmap_hdr, and as in
PF_PACKET's tpacket2_hdr and tpacket3_hdr ?
