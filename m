From: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Subject: Re: [PATCH] iproute2 -- add fwmarkmask
Date: Thu, 23 Feb 2006 14:39:32 -0500
Message-ID: <18992.1140723572@sandelman.ottawa.on.ca>
References: <23395.1140452828@sandelman.ottawa.on.ca>
	<43F9F648.1060803@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: Message from Patrick McHardy <kaber@trash.net>
	of "Mon, 20 Feb 2006 18:03:04 +0100." <43F9F648.1060803@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1


>>>>> "Patrick" == Patrick McHardy <kaber@trash.net> writes:
    Patrick> The normal way to display masks is with a "/". Also I think
    Patrick> it shouldn't display the default mask to avoid breaking
    Patrick> scripts that parse the output.

  I generally dislike the /VALUE, since I expect /PREFIX-LEN.
  I agree that it shouldn't show if it is default.

    Patrick> ip should be able to parse its own output, and it would
    Patrick> also look nicer if I could just say "fwmark
    Patrick> 0x1/32". fwmarkmask is really an incredible ugly expression
    Patrick> :)

  Sure. Is that a 32-bit long mask (0xfffffff), or is it a 0x00000020?
  fwmark is not an address.

  Or would you like /32 to be a prefix-based mask, and &value and/or
fwmarkmask to be a value? 

- -- 
]       ON HUMILITY: to err is human. To moo, bovine.           |  firewalls  [
]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
] mcr@xelerance.com      http://www.sandelman.ottawa.on.ca/mcr/ |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Finger me for keys

iQEUAwUBQ/4PcoCLcPvd0N1lAQIHhQf3XzPLA91QEx2+XpmYIm8RyB1oKmUUXDP+
s2UrhOKbQwipcq8/hk1t4FKx8J5j/dFHzVXbgPK+ZUwX4+IjHmM3r0sCIcK08xwU
/ZZjf0wqwUI+RcPRFw3zC0+hnwRUIAUxhl3p7h3PigDpPu7AY5tQ1dXc6WNwRjTi
fS7Yozbo225dzvVLKHhSIqOQ4eJFJcPPQdTKQLxnc3gtVoSe41DKMM+x6uix6fG8
se9dngJRbhye1Xgws9AGnBQT9f7JVmCSv7V4SHnNynmnRw3cra8++QEnLZ/vhm5C
JdeVSeDGxAPuKEj6HA2RZu/UOG6RkYNZGPovGKzuPn403x0HNBuf
=BzfV
-----END PGP SIGNATURE-----
