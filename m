From: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Subject: Re: [PATCH 02/10] netfilter: nf_log: prepar net namespace support
	for nf_log
Date: Tue, 5 Nov 2013 11:14:55 -0300
Message-ID: <20131105141455.GB22912@ghostprotocols.net>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1360223390-15589-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lve-ke3WRBg/xIg@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1360223390-15589-2-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Thu, Feb 07, 2013 at 03:49:42PM +0800, Gao feng escreveu:
> index 9e31269..b1e5126 100644
> +++ b/net/netfilter/nf_log.c
> @@ -16,7 +16,6 @@
>  #define NF_LOG_PREFIXLEN		128
>  #define NFLOGGER_NAME_LEN		64
>  
> -static const struct nf_logger __rcu *nf_loggers[NFPROTO_NUMPROTO] __read_mostly;

This was initialized to zeros, but then got moved to struct netns_nf,
I'm trying to figure it out if it is being zeroed somewhere, ideas?

- Arnaldo
