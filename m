From: Fernando Gont <fernando@gont.com.ar>
Subject: Improved handling of IPv6 atomic fragments (FO=0, MF=0)
Date: Mon, 30 Jan 2012 07:24:22 -0300
Message-ID: <4F266FD6.4070301@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: security@kernel.org, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44745 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab2A3KY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 05:24:26 -0500
Received: by yhoo21 with SMTP id o21so1650546yho.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 02:24:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

FYI. We have published an IETF I-D that proposes an improved handling of
IPv6 atomic fragments (IPv6 fragments that have an offset of 0, and MF=0).

The I-D is available here:
<http://tools.ietf.org/id/draft-gont-6man-ipv6-atomic-fragments-00.txt>

The aforementioned behaviour eliminates fragmentation-based attacks
against traffic that employs atomic fragments, and has already been
implemented by OpenBSD.

Thanks,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
