From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 30 Jan 2005 19:09:38 -0500
Message-ID: <1107130177.7847.96.camel@jzny.localdomain>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>
	 <1105019912.2314.20.camel@jzny.localdomain>
	 <1105023972.3462.48.camel@tsc-6.cph.tpack.net>
	 <1105104757.1046.63.camel@jzny.localdomain>
	 <1105111605.3462.101.camel@tsc-6.cph.tpack.net>
	 <1105363092.1041.146.camel@jzny.localdomain>
	 <1105917038.1091.1041.camel@jzny.localdomain> <41EC3067.6050104@tpack.net>
	 <41FD702D.2060403@tpack.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41FD702D.2060403@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy,

I wasnt sure why you did:

dev->qdisc = &noop_qdisc;

You should probably save the old qdisc in qdisc_sleeping instead
and restore it on wakeup - otherwise you always end with default qdisc.
check_carrier should probably just call dev_activate which does all you
wanted, no?

cheers,
jamal
