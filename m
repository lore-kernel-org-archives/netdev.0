From: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: MDNS is broken in latest -git
Date: Fri, 28 May 2010 20:09:51 +0300
Message-ID: <1275066591.3390.4.camel@maxim-laptop>
References: <1275058948.2754.7.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1275058948.2754.7.camel@maxim-laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-05-28 at 18:02 +0300, Maxim Levitsky wrote: 
> On latest git, it became impossible to use hostname.local alias to
> access my network hosts.
> 
> In fact when I look at 'avahi-discover' I see nothing but local
> services.
> 
> I did a bisect, but unfortunely ended with merge commit, although
> bisection seem to be normal (and I didn't do any shortcuts).

Since starting 'wireshark' magicly temporarly fixes this, I suspect that
mulicast packets don't get through.

This smells like iwl3945 bug.

I use linus' master tree now.

Best regards,
Maxim Levitsky

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
