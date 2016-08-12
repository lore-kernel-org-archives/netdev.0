From: Florian Westphal <fw@strlen.de>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Fri, 12 Aug 2016 21:03:19 +0200
Message-ID: <20160812190319.GB25519@breakpoint.cc>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160729132154.GB13634@breakpoint.cc>
 <BL2PR07MB2306B2B920C441DF5406B1439E050@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160802221121.GB31209@breakpoint.cc>
 <BL2PR07MB23061A24DD64E80532DBD9799E060@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB2306C9A7EB393F441D56E7D69E1E0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Brandon Cazander <brandon.cazander@multapplied.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:60098 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752194AbcHLTDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 15:03:22 -0400
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306C9A7EB393F441D56E7D69E1E0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandon Cazander <brandon.cazander@multapplied.net> wrote:
> Is there anything I can provide or do to help get this issue fixed? Even with the patch provided, our application is still broken.

[..]

> I think that it is worth doing, as the original kernel change broke my user space program and could do the same to others as well.
> 
> On another setup, even with the DIVERT rule in place, I'm still seeing the RST after the ACK. I'm not sure how it is behaving differently than the other setup so I need to look into that. But it definitely worked before the changes to the kernel.

Well, what is different in that setup?
(e.g. rules, application binding different ip address, etc)

Once I can re-create the problem chances for a fix will be a bit
higher...
