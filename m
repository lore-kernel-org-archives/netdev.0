From: "David S. Miller" <davem@redhat.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Fri, 6 Feb 2004 20:24:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206202438.13163677.davem@redhat.com>
References: <20040206195325.207aa1c7.davem@redhat.com>
	<OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hibi665@oki.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Feb 2004 21:12:59 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> @@ -211,16 +219,11 @@
> 
>  int ip6_mc_input(struct sk_buff *skb)
>  {
> -     struct ipv6hdr *hdr;
> -     int deliver = 0;
> +     int deliver = 1;
>       int discard = 1;

'deliver' is always true now, please kill it and all the code
trying to test it :)
