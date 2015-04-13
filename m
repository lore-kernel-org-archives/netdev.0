From: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Subject: Re: [PATCH 1/4] ipv4: add option to drop unicast encapsulated in L2
 multicast
Date: Mon, 13 Apr 2015 15:04:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1504131437040.1627@ja.home.ssi.bg>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>   <alpine.LFD.2.11.1504101445330.1538@ja.home.ssi.bg>  <1428671435.1890.22.camel@sipsolutions.net>  <alpine.LFD.2.11.1504111305440.2449@ja.home.ssi.bg>
 <1428922636.2355.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428922636.2355.7.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 13 Apr 2015, Johannes Berg wrote:

> > - CLUSTERIP works in LOCAL_IN (after ip_rcv_finish), LOCAL_IN
> > is here: ip_rcv_finish->dst_input->ip_local_deliver->
> > ip_local_deliver_finish
> 
> It's just that the later this is, the more nervous I get about it being
> really effective. :)
> 
> I'm willing to discount the CLUSTERIP case, it seems insane to want to
> run CLUSTERIP over wifi on a network that explicitly limits multicast.
> 
> Other than that, do you see any reason for not putting it in
> ip_rcv_finish()?

	ok, I don't remember for other cases.

Regards

--
Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
