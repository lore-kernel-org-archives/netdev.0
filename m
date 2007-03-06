From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] ARP notify option
Date: Tue, 6 Mar 2007 14:52:41 -0800
Message-ID: <20070306145241.5ec1c511@freekitty>
References: <20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
	<20070305.203536.92584097.davem@davemloft.net>
	<20070306105132.52c77491@freekitty> <45EDDA8F.5060106@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, jeff@garzik.org, ian.pratt@xensource.com,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, akpm@linux-foundation.org,
   David Miller <davem@davemloft.net>, ak@muc.de
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <virtualization-bounces@lists.osdl.org>
In-Reply-To: <45EDDA8F.5060106@nortel.com>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.osdl.org>
List-Help: <mailto:virtualization-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=subscribe>
Sender: virtualization-bounces@lists.osdl.org
Errors-To: virtualization-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Mar 2007 15:18:07 -0600
"Chris Friesen" <cfriesen@nortel.com> wrote:

> Stephen Hemminger wrote:
> =

> > +arp_notify - BOOLEAN
> > +	Define mode for notification of address and device changes.
> > +	0 - (default): do nothing
> > +	1 - Generate gratuitous arp replies when device is brought up
> > +	    or hardware address changes.
> =

> Did you consider using gratuitous arp requests instead?  I remember =

> reading about some hardware that updated its arp cache on gratuitous =

> requests but not gratuitous replies.
> =

> Chris

I copied the ARP generation from other places that were doing
gratuitous ARP already:  Xen and irlan.
Our local switch used REPLY's to do the same thing.

One could imagine making it a ternary value and having 2 generate
REQUEST's.


-- =

Stephen Hemminger <shemminger@linux-foundation.org>
