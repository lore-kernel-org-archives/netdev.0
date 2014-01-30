From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: Fwd: RFC 7112 on Implications of Oversized IPv6 Header Chains
Date: Thu, 30 Jan 2014 12:00:07 -0300
Message-ID: <52EA68F7.8040604@gont.com.ar>
References: <20140129173044.D475C7FC17B@rfc-editor.org>	 <52E955A3.7080408@gont.com.ar> <1391090198.4405.57.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:36681 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbaA3QXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 11:23:43 -0500
In-Reply-To: <1391090198.4405.57.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/30/2014 10:56 AM, Ben Hutchings wrote:
> On Wed, 2014-01-29 at 16:25 -0300, Fernando Gont wrote:
>> Folks,
>> 
>> FYI. This one has important implications -- it allows stateless 
>> filtering in IPv6 (otherwise not really possible)
> [...]
> 
> Still not possible unless you can trust that all hosts behind the 
> firewall will correctly drop overlapping fragments.

All recent versions of popular OSes already do that.

Yes, there will be older ones around for a while -- but so many things
have and are being improved in the IPv6 area that, if you ran an old
OS, processing overlapping fragments should probably be the last thing
you should worry about.

Thanks,
- -- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1



-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJS6mjuAAoJEJbuqe/Qdv/x3e0H/iwSar/7m9XJr6/6QOt6Nst5
gbvAOzd2PgtjwGuRYHT0rSwZi2+/Ju7CRoiBjsTpMuAVtpYYt9+1+RX20W1Q0VpA
QVKlQUKoOeL00jNLjWGVCG8rJtDhE5Q+oi5hynjrWtphEQ3mNeHCn+bfW/Jbu0R6
oFv6uOkMiRNvdcVGkXxf6cNeZ9uE4w2pTOIXHbZekl6ejfUjkn5z8u5VlckDS7QR
ct3NPSKSOMv0C/3q+ncuZeUp2ids5BiyxBUzhJvxH2YG8/CYL5gjjOi/YbTDdz+3
TKM/ZB13U1ZqoTpWgYjr8o4UPR14Ek/GTCwrHYY6O9X5Y8FgXoQZePrItqexR0Y=
=CQDC
-----END PGP SIGNATURE-----
