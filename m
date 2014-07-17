From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 0/2] net: print net_device name/state more
 often
Date: Thu, 17 Jul 2014 14:48:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17276E6E@AcuExch.aculab.com>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Gundersen <teg@jklm.no>
To: 'Veaceslav Falico' <vfalico@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48238 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934102AbaGQOtT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 10:49:19 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26732-07 for <netdev@vger.kernel.org>;
 Thu, 17 Jul 2014 15:49:10 +0100 (BST)
In-Reply-To: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico
> Currently we use net_device->name only if it's the NETREG_REGISTERED
> reg_state, otherwise we return "(unregistered device)".
> 
> However, we always populate net_device->name on creation, so it's always
> available to us for use. The only caveat is that we might have a name like
> "eth%d", in which case we cannot use it as it might change in the future.

While you've got this code out on the operating table what about:
1) Tracing the renames into the kernel message buffer.
2) Including the original name in some of the kernel traces.

I've been trying to diagnose some issues on a system that renames
its interfaces, and it can get tricky working out which interface
messages refer to.

	David
