From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] ipv4: tcp: security_sk_alloc() needed for unicast_sock
Date: Thu, 9 Aug 2012 16:19:03 -0400
Message-ID: <CAHC9VhQo8bh45qcMDo3cC=a0RA50zwBMftbZ3KGdLEXUapuvtw@mail.gmail.com>
References: <50215A7E.8000701@linaro.org>
	<1344462889.28967.328.camel@edumazet-glaptop>
	<5022FD9A.4020603@schaufler-ca.com>
	<1695034.0lrQgQPOMT@sifl>
	<1344523833.28967.996.camel@edumazet-glaptop>
	<CACLa4ptkvKj2GT4ZL+msMuWOHW885Hugk8nz3hvptOoY9-totw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org,
        john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
        LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
In-Reply-To: <CACLa4ptkvKj2GT4ZL+msMuWOHW885Hugk8nz3hvptOoY9-totw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: owner-selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 9, 2012 at 4:06 PM, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org> wrote:
> I'm going to work right now on exposing the equivalent struct sock LSM
> interface so we can call that as well.  But it's going to take me a
> bit.

Before you go too far down this path, can you elaborate on what
exactly you mean by the above?

I'm asking because I'm not convinced the labeling, either the old way
or the new way, was 100% correct and I think we're going to need to
change things regardless.  I'm just not sure what the right solution
is just yet.

-- 
paul moore
www.paul-moore.com
