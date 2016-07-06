From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] (resend) ixgbe: always initialize setup_fc
Date: Wed, 6 Jul 2016 23:00:51 +0000
Message-ID: <038AE347-E85C-4738-BC91-C8C16AE88620@intel.com>
References: <CAE2NFgXe4uPT1WDVzSq_rr54XA7xDNuedoBgHdtd2_WekNQZ+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_1BA0D022-6C8A-4414-B814-A95D3049CF10";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McLean <patrickm@gaikai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49080 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbcGFXEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 19:04:06 -0400
In-Reply-To: <CAE2NFgXe4uPT1WDVzSq_rr54XA7xDNuedoBgHdtd2_WekNQZ+A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_1BA0D022-6C8A-4414-B814-A95D3049CF10
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Patrick McLean <patrickm@gaikai.com> wrote:

> Gmail mangled my first message, sorry about that. Second attempt.
>
> In ixgbe_init_mac_link_ops_X550em, the code has a special case for
> backplane media type, but does not fall through to the default case,
> so the setup_fc never gets initialized. This causes a panic when it
> later tries to set up the card, and the kernel dereferences the null
> pointer.
>
> This patch lets the the function fall through, which initialized
> setup_fc properly.

I don't think that this is the right fix. My memory is that fc autoneg is  
not supported in that configuration, so setup_fc is intended to be NULL. I  
think it is the reference that needs to have a check added.
--Apple-Mail=_1BA0D022-6C8A-4414-B814-A95D3049CF10--
