From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 17 Jan 2005 14:04:19 +0200
Message-ID: <200501171404.19451.hasso@estpak.ee>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com> <1105363092.1041.146.camel@jzny.localdomain> <1105917038.1091.1041.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tommy Christensen <tommy.christensen@tpack.net>,
        Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1105917038.1091.1041.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Didnt see anymore discussion on this - have we given up on it?

I'm not competent enough about kernel internals to decide how this should be 
done in kernel. But I would like to clarify situation for me as Quagga 
developer.

All this work is done to avoid sending stale packets to the network? Ie. 
there will be no change regarding socket blocking issue? Detecting carrier 
on/off and/or socket per interface is must be for us in user space to avoid 
socket blocking? I'm just trying to have full picture so I can put my 
priorities in place for next release.


Thanks for your support,

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
