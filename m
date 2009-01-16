From: Jan-Bernd Themann <THEMANN@de.ibm.com>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Fri, 16 Jan 2009 10:15:57 +0100
Message-ID: <OFB1959A4E.46C59583-ONC1257540.0031805B-C1257540.0032E64E__41524.9879392379$1232097572$gmane$org@de.ibm.com>
References: <20090115214056.GC9091@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0215480609=="
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090115214056.GC9091@ovro.caltech.edu>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============0215480609==
Content-Type: multipart/alternative; boundary="=_alternative 0032E64DC1257540_="

This is a multipart message in MIME format.
--=_alternative 0032E64DC1257540_=
Content-Type: text/plain; charset="US-ASCII"

Hi!

Ira Snyder <iws@ovro.caltech.edu> wrote on 15.01.2009 22:40:56:

> On Thu, Jan 15, 2009 at 10:22:53PM +0100, Arnd Bergmann wrote:
> > On Thursday 15 January 2009, Ira Snyder wrote:
> > > I have another question for you Arnd.
> > > 
> > > What did you use as the host and guest drivers when you ran virtio 
over
> > > PCI? Did you use two unmodified instances of virtio_net (one on 
host,
> > > one on guest) for networking, or did you write new virtio drivers 
for
> > > those? How about for virtio_console (if you ran it at all).

In addition to what Arnd already told you: 
We used two (almost) unmodified instances of virtio_net. When we tested 
this
driver we modified the change_mtu function slightly as this function was 
not implemented
properly (for our purpose) at that time. 

> > 
> > Jan-Bernd may be able to tell you details about this, and send you the
> > driver code that his interns implemented for it.
> > This was only doing virtio_net between two machines using MMIO 
transfers,
> > i.e. the DMA engine was unused, but there was a mailbox interrupt (if 
you
> > have one of these, you won't need MSI, btw -- just write a DMA to it).
> > 
> 
> Thanks. Jan-Bernd, I'm looking forward to any input you have.
> 

Regards,
Jan-Bernd
--=_alternative 0032E64DC1257540_=
Content-Type: text/html; charset="US-ASCII"


<br><tt><font size=2>Hi!</font></tt>
<br>
<br><tt><font size=2>Ira Snyder &lt;iws@ovro.caltech.edu&gt; wrote on 15.01.2009
22:40:56:<br>
<br>
&gt; On Thu, Jan 15, 2009 at 10:22:53PM +0100, Arnd Bergmann wrote:<br>
&gt; &gt; On Thursday 15 January 2009, Ira Snyder wrote:<br>
&gt; &gt; &gt; I have another question for you Arnd.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; What did you use as the host and guest drivers when you
ran virtio over<br>
&gt; &gt; &gt; PCI? Did you use two unmodified instances of virtio_net
(one on host,<br>
&gt; &gt; &gt; one on guest) for networking, or did you write new virtio
drivers for<br>
&gt; &gt; &gt; those? How about for virtio_console (if you ran it at all).</font></tt>
<br>
<br><tt><font size=2>In addition to what Arnd already told you: </font></tt>
<br><tt><font size=2>We used two (almost) unmodified instances of virtio_net.
When we tested this</font></tt>
<br><tt><font size=2>driver we modified the change_mtu function slightly
as this function was not implemented</font></tt>
<br><tt><font size=2>properly (for our purpose) at that time. </font></tt>
<br><tt><font size=2><br>
&gt; &gt; <br>
&gt; &gt; Jan-Bernd may be able to tell you details about this, and send
you the<br>
&gt; &gt; driver code that his interns implemented for it.<br>
&gt; &gt; This was only doing virtio_net between two machines using MMIO
transfers,<br>
&gt; &gt; i.e. the DMA engine was unused, but there was a mailbox interrupt
(if you<br>
&gt; &gt; have one of these, you won't need MSI, btw -- just write a DMA
to it).<br>
&gt; &gt; <br>
&gt; <br>
&gt; Thanks. Jan-Bernd, I'm looking forward to any input you have.<br>
&gt; <br>
</font></tt>
<br><tt><font size=2>Regards,</font></tt>
<br><tt><font size=2>Jan-Bernd</font></tt>
--=_alternative 0032E64DC1257540_=--

--===============0215480609==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0215480609==--
