From: Fernando Gont <fernando@gont.com.ar>
Subject: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Tue, 27 Nov 2012 11:54:50 -0300
Message-ID: <50B4D43A.7030208@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:46718 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875Ab2K0PVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 10:21:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

FYI. This is might affect Linux users employing e.g. OpenVPN:
<http://tools.ietf.org/html/draft-gont-opsec-vpn-leakages>.

For a project such as OpenVPN, a (portable) fix might be non-trivial.
However, I guess Linux might hook some iptables rules when establishing
the VPN tunnel, such that e.g. all v6 traffic is filtered (yes, this is
certainly not the most desirable fix, but still probably better than
having your supposedly-secured traffic being sent in the clear).

P.S.: Not sure if this is the right list to send this note. Please
advice of a more appropriate one and/or feel free to forward this note
if deemed appropriate...

Thanks,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
