From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 13 Mar 2005 19:49:13 +0200
Message-ID: <200503131949.13962.hasso@estpak.ee>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com> <1107142012.8021.109.camel@jzny.localdomain> <1107173804.5812.133.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <1107173804.5812.133.camel@tsc-6.cph.tpack.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> On Mon, 2005-01-31 at 04:26, jamal wrote:
> > It does look pretty sane.. Tested?
>
> Nope, I don't have access to any relevant HW. Hopefully someone
> else can give it some beating. Please.

Sorry for long delay. I lost track in this discussion, was busy with other 
things, but found finally time to test this.

> Hopefully someone can verify that with e.g. an e1000, and then check
> whether the patch I send makes any difference.

Yes, confirmed that patch makes difference and solves Quagga ospfd problem 
(from what it all started :).

Thank you very much!


PS. Patch is tested with 2.4.29 as well, but it requires link watch stuff to 
work. Complete (link-watch + vlan carrier detection + this fix) is here - 
http://hasso.linux.ee/quagga/2.4.29-link-watch.patch

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
