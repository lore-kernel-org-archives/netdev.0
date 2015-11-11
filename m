From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH RESEND] net: Documentation: Fix default value
 tcp_limit_output_bytes
Date: Wed, 11 Nov 2015 09:50:02 -0700
Message-ID: <20151111095002.2311dada@xps>
References: <1447077529-9200-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: <edumazet@google.com>, <tom@herbertland.com>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Niklas Cassel <niklass@axis.com>, netdev@vger.kernel.org
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1447077529-9200-1-git-send-email-niklass@axis.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Nov 2015 14:58:49 +0100
Niklas Cassel <niklas.cassel@axis.com> wrote:

> Commit c39c4c6abb89 ("tcp: double default TSQ output bytes limit")
> updated default value for tcp_limit_output_bytes

I left this last time because Dave usually likes to pick up networking
docs patches himself.  This wasn't sent to netdev, though, so that's
unlikely to happen.  I've gone ahead and applied it, since it seems
clearly correct.

Thanks,

jon

> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> ---
>  Documentation/networking/ip-sysctl.txt | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 05915be..2ea4c45 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -709,7 +709,7 @@ tcp_limit_output_bytes - INTEGER
>  	typical pfifo_fast qdiscs.
>  	tcp_limit_output_bytes limits the number of bytes on qdisc
>  	or device to reduce artificial RTT/cwnd and reduce bufferbloat.
> -	Default: 131072
> +	Default: 262144
>  
>  tcp_challenge_ack_limit - INTEGER
>  	Limits number of Challenge ACK sent per second, as recommended
> -- 
> 2.1.4
> 
