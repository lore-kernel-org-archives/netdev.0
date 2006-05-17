From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] SECMARK 1.1
Date: Wed, 17 May 2006 10:56:04 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605171053120.25450@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
 <Pine.LNX.4.64.0605140133560.5506@d.namei> <20060517133653.GA7327@thorium.jmh.mhn.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>,
	Karl MacMillan <kmacmillan@tresys.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:48311 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750915AbWEQO4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 10:56:07 -0400
To: Thomas Bleher <bleher@informatik.uni-muenchen.de>
In-Reply-To: <20060517133653.GA7327@thorium.jmh.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 May 2006, Thomas Bleher wrote:

> This all looks very nice - Thank You!
> Just one question: does the code canonicalize the security label? It
> would be nice if the same rules could be used on MLS and non-MLS
> systems.

No, it shouldn't be necessary, as there's no legacy installed base of 
rulesets (as there was with disk files), and MLS is now generally enabled 
by default.  Also, these rules are never exposed to general users, and 
even sysadmins should generate the rules via some kind of tool.

It would also add some complexity.


- James
-- 
James Morris
<jmorris@namei.org>
