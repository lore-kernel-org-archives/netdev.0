From: jamal <hadi@cyberus.ca>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Wed, 4 Dec 2002 08:11:27 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0212040806590.2731-100000@shell.cyberus.ca>
References: <3DED51E9.1080408@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stefan Rompf <srompf@isg.de>, "David S. Miller" <davem@redhat.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3DED51E9.1080408@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Tue, 3 Dec 2002, Jeff Garzik wrote:

> Pardon my dumb question, but what parts of RFC2863 require kernel
> additions over and above your link state patch?
>
> Your second patch I am less enthusiastic about than the first... :(
>
> I wonder if userspace cannot figure out ifOperStatus from existing data
> we make available?
>

Stefans curtrent patch makes the info available via netlink.
What dont you like about it Jeff? Take a quick look at RFC2863
and scan for IfAdminStatus and IfOperStatus. The modelling RFC2863
has is pretty good and thats what Stefan has followed (after we weeded
a few crappy pieces off the RFC; we discussed on netdev).

cheers,
jamal
