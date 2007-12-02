From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 13/21] [TCP]: Store retransmit queue packets in RB tree.
Date: Sun, 2 Dec 2007 13:20:38 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712021133250.4539@kivilampi-30.cs.helsinki.fi>
References: <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492973133-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071202002334.GA14334@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-710486826-1196588131=:4539"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47550 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755847AbXLBLUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 06:20:40 -0500
In-Reply-To: <20071202002334.GA14334@gondor.apana.org.au>
Content-ID: <Pine.LNX.4.64.0712021316150.6477@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-710486826-1196588131=:4539
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712021138381.4748@kivilampi-30.cs.helsinki.fi>

On Sun, 2 Dec 2007, Herbert Xu wrote:

> On Sun, Dec 02, 2007 at 12:48:08AM +0200, Ilpo Järvinen wrote:
> > 
> > This work was mostly done by David S. Miller.
> 
> ...
> 
> > @@ -253,6 +254,8 @@ struct sk_buff {
> >  	struct sk_buff		*next;
> >  	struct sk_buff		*prev;
> > 
> > +	struct rb_node		rb;
> 
> Did David really do this? :)

...Believe it or not, yes he did :-), and there's even a more convicing 
proof about that in here:

http://marc.info/?l=linux-netdev&m=117269223013422&w=2

...and in Dave's obsolete tcp-2.6 tree (which has the bug fixed 
version)... ;-)

...I changed it by just by moving tp->write_queue_rb = RB_ROOT to another 
function because I needed more initialization later on.

> I suppose if we moved this into cb (by growing it by the required amount)
> then at least the new space can be used by others.

...yeah, will do.


-- 
 i.
---696243703-710486826-1196588131=:4539--
