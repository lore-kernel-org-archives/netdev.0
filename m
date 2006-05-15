From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] SECMARK 1.1
Date: Mon, 15 May 2006 08:43:40 +0200
Message-ID: <4468231C.6090209@trash.net>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei> <Pine.LNX.4.64.0605140133560.5506@d.namei> <446778F0.6000705@trash.net> <Pine.LNX.4.64.0605150004590.645@d.namei> <446811D3.5080905@trash.net> <Pine.LNX.4.64.0605150153590.1275@d.namei> <446819FE.8050300@trash.net> <Pine.LNX.4.64.0605150221000.1275@d.namei> <44681F0F.9030601@trash.net> <Pine.LNX.4.64.0605150236270.1824@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>,
	Karl MacMillan <kmacmillan@tresys.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Bleher <bleher@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42886 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932343AbWEOGnn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 02:43:43 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605150236270.1824@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Mon, 15 May 2006, Patrick McHardy wrote:
> 
> 
>>But if you don't specify --track, the module loader will still have to
>>resolve the symbol, so it gets loaded anyway, before your code will
>>even run. Just look at need_conntrack():
> 
> 
> Doh.  It should be try_module_get().  Sound ok?

try_module_get already needs a module reference, so this won't work
either. As far as I can tell the only thing you can do besides
putting it in a seperate module is to manually call request_module().

