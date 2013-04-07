From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH 4/5] tipc: add InfiniBand media type
Date: Sun, 07 Apr 2013 11:19:06 +0200
Message-ID: <51613A0A.3060706@acm.org>
References: <1364993010-15515-1-git-send-email-kaber@trash.net> <1364993010-15515-5-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org, allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364993010-15515-5-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/03/13 14:43, Patrick McHardy wrote:
> diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
> +#ifdef CONFIG_TIPC_MEDIA_IB
> +int  tipc_ib_media_start(void);
> +void tipc_ib_media_stop(void);
> +#else
> +int  tipc_ib_media_start(void) { return 0; }
> +void tipc_ib_media_stop(void)  { return; }
> +#endif

Is the above a definition of a non-inline function pair in a header file 
? I'm afraid that will cause trouble when including that header file in 
more than one source file.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
