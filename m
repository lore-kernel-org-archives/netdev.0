From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: Re: [PATCH] net/ipv6: Fix CALIPSO causing GPF with datagram support
Date: Mon, 5 Jun 2017 18:20:28 +0100
Message-ID: <20170605172028.GA2513@merlot.physics.ox.ac.uk>
References: <20170605154440.2434-1-richard_c_haines@btinternet.com>
 <CAHC9VhRwzC=XTRj5gNfd11T=XzpYSrVfu-jnx9f4__duMAji1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAHC9VhRwzC=XTRj5gNfd11T=XzpYSrVfu-jnx9f4__duMAji1Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2017 at 11:55:34AM -0400, Paul Moore wrote:
> On Mon, Jun 5, 2017 at 11:44 AM, Richard Haines
> <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org> wrote:
> > When using CALIPSO with IPPROTO_UDP it is possible to trigger a GPF as the
> > IP header may have moved.
> >
> > Also update the payload length after adding the CALIPSO option.
> >
> > Signed-off-by: Richard Haines <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
> > ---
> >  net/ipv6/calipso.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> Acked-by: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
