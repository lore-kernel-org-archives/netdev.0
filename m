From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH] ipv4: tcp: security_sk_alloc() needed for unicast_sock
Date: Thu, 09 Aug 2012 15:26:53 -0700
Message-ID: <5024392D.3060608@schaufler-ca.com>
References: <50215A7E.8000701@linaro.org>  <1344462889.28967.328.camel@edumazet-glaptop>  <5022FD9A.4020603@schaufler-ca.com> <1695034.0lrQgQPOMT@sifl>  <1344523833.28967.996.camel@edumazet-glaptop>  <CACLa4ptkvKj2GT4ZL+msMuWOHW885Hugk8nz3hvptOoY9-totw@mail.gmail.com>  <1344547743.31104.582.camel@edumazet-glaptop>  <5024313F.1010404@schaufler-ca.com> <1344549920.31104.701.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org,
        john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
        LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
In-Reply-To: <1344549920.31104.701.camel@edumazet-glaptop>
Sender: owner-selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8/9/2012 3:05 PM, Eric Dumazet wrote:
> On Thu, 2012-08-09 at 14:53 -0700, Casey Schaufler wrote:
>> On 8/9/2012 2:29 PM, Eric Dumazet wrote:
>>> smack_sk_alloc_security() uses smk_of_current(): What can be the
> I repeat: There are no true socket for these control packets.

OK, fine. You have an optimization. I'm good with that. Just don't
expect that the entire software stack you are taking advantage of
is going to change to accommodate your special case.
