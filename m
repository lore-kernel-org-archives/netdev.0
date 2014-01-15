From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4 0/7] Intel Wired LAN Driver Updates, ixgbe: Add
 LER support
Date: Tue, 14 Jan 2014 18:59:53 -0800 (PST)
Message-ID: <20140114.185953.1231061732271688717.davem@davemloft.net>
References: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	mark.d.rustad@intel.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaAOC7z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:59:55 -0500
In-Reply-To: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Aaron Brown <aaron.f.brown@intel.com>
Date: Tue, 14 Jan 2014 18:53:10 -0800

> The following patches add Live Error Recovery (LER) support to the
> ixgbe driver. This support also improves behavior in Thunderbolt
> environments. This involves checking all register reads for a
> value of all ones and when that is seen, to read the status
> register, which should never properly return all ones, to
> confirm whether the received value was correct. When this detects
> a removal, the hw_addr field is cleared to indicate the removal.
> This then blocks subsequent access to the device registers.
>=20
> All register access macros have been changed to static inline
> functions and all register accesses now use them.=B7 Macro versions
> are temporarily provided.
>=20
> The __IXGBE_DOWN bit is no longer overloaded to also mean that
> device removal has been initiated. Now the bit can be used to
> protect ixgbe_down from multiple entry via test_and_set_bit. A
> needed smp_mb__before_clear_bit was also added.
 ...

Looks good, series applied, thanks Aaron.
