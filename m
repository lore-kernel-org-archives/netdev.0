From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: NFS root + iptables in 2.6.25
Date: Fri, 19 Sep 2008 02:00:57 -0700
Message-ID: <20080919020057.f2f256fe.akpm@linux-foundation.org>
References: <48D3451D.1080807@dgt.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wojciech Kromer <wojciech.kromer-m/c5HOfTwvjVItvQsEIGlw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48D3451D.1080807-m/c5HOfTwvjVItvQsEIGlw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Sep 2008 08:22:21 +0200 Wojciech Kromer <wojciech.kromer-m/c5HOfTwvjVItvQsEIGlw@public.gmane.org> wrote:

> Hi.
> 
> I'm using nfs root filesystem for developing.
> On 2.6.23 everything works fine, but on 2.6.25 loading any iptables
> module causes problems:
> 
> 
> # modprobe iptable_nat
> nf_conntrack version 0.5.0 (1024 buckets, 4096 max)
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> nfs: RPC call returned error 1
> 
> 
> Probably iptables changed it's default behavior from "allow all" to
> "deny all" at startup.
> Is there any way to change it back?
> I can't change anything after loading any iptable module, because all
> programs on filesystem are not accessible after loading...
> 
> 

(cc's added)

(googles "nfs: RPC call returned error 1")

hm, there has been a dribble of reports going back several years, but
nothing conclusive afaict.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
