From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: 18 Aug 2003 09:03:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061211833.16010.2202.camel@jzny.localdomain>
References: <20030818091312.GA4889@lapdog>
	 <20030818041911.358c3437.davem@redhat.com>
	 <1061208824.16010.2119.camel@jzny.localdomain>
	 <20030818051227.4f35f2f3.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tv@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030818051227.4f35f2f3.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is fine by me. I 'll let Tommi take the lead on it unless he is too
busy.

cheers,
jamal

On Mon, 2003-08-18 at 08:12, David S. Miller wrote:
> On 18 Aug 2003 08:13:44 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > Editing the header may be the better approach if you have a few hundred 
> > hhs already inserted (this was the issue i was faced with when VRRP was
> > failing over when i was playing with it). I tried to flush the cache but
> > it took longer to recover it. 
> 
> There is another reason I want the cache flushed.
> 
> Those hh cache entries are what ARP resolved to when we
> had the previous MAC address, not the one we have now.
> 
> The ARPs may come back differently with the new MAC
> address.
> 
> I _REALLY REALLY_ don't want to have to change the
> ->update() implementations.  Although one thing I
> would consider is a new ->update_src() operation
> and if this were NULL we flush the entries instead.
> 
> 
