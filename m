From: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Subject: Re: [PATCH 02/02] add mask options to fwmark masking code
Date: Thu, 23 Feb 2006 14:36:58 -0500
Message-ID: <16464.1140723418@sandelman.ottawa.on.ca>
References: <23140.1140452813@sandelman.ottawa.on.ca>
	<43F9F4E7.5000708@trash.net>
Cc: kuznet@ms2.inr.ac.ru, netfilter-devel <netfilter-devel@lists.netfilter.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: Message from Patrick McHardy <kaber@trash.net>
	of "Mon, 20 Feb 2006 17:57:11 +0100." <43F9F4E7.5000708@trash.net>
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
    >> #define RTA_FWMARK RTA_PROTOINFO +#define RTA_FWMARK_MASK
    >> RTA_CACHEINFO

    Patrick> Please introduce a new attribute for this instead of
    Patrick> overloading RTA_CACHEINFO.

  I would be happy to do that.
  Should I also un-overload FWMARK, with backwards compatibility?

    >> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c index
    >> de327b3..69eed89 100644 --- a/net/ipv4/fib_rules.c +++
    >> b/net/ipv4/fib_rules.c @@ -68,6 +68,7 @@ struct fib_rule u8
    >> r_tos; #ifdef CONFIG_IP_ROUTE_FWMARK u32 r_fwmark; + u32
    >> r_fwmark_mask;

    Patrick> Both patches have whitespace issues. You should also change

  uhm. okay.
  I'm surprised, since I produced it with git-format-patch. Maybe there
are tabs that emacs screwed up.

- -- 
]       ON HUMILITY: to err is human. To moo, bovine.           |  firewalls  [
]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
] mcr@xelerance.com      http://www.sandelman.ottawa.on.ca/mcr/ |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Finger me for keys

iQEVAwUBQ/4O2ICLcPvd0N1lAQK/egf6A0iQ1hvecR4BeaCrQiu53beGZd6zHldk
o6logfar94kPP/H/D/kMcNeAvL2a3cJ8wyfyP02Cav8gP1C3X+XV+yLtA9jHIrdK
nqQ1gw7F4Cj2+v7du/jS8GxNMWevXhJ7f9hvnzh8+DHMUCjqiksgsuIgcRQYrqOQ
vxYERvR5TojEIaJfg8kH/lJRn3sm/APuMphM6c6SAeqrWpAdijbZb4LSNpGH50ci
nNhUp+FxoP8vVFTMTu7M1MK4fpCIWA/PxBkmy3YDhcQx1+mE2nrEqHdbKfx9uY+t
0mxR8UC5sthhn94/VCjcqWOoHe3S/Gi+WWoPtwN1sFe5BujwU7Vcfw==
=yKIA
-----END PGP SIGNATURE-----
