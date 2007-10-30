From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Tue, 30 Oct 2007 15:35:10 +1100
Message-ID: <18214.46206.94270.229728@notabene.brown>
References: <471C893F.6000306@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35773 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbXJ3EfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 00:35:17 -0400
In-Reply-To: message from Aurelien Charbon on Monday October 22
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday October 22, aurelien.charbon@ext.bull.net wrote:
> Here is a second missing part of the IPv6 support in NFS server code 
> concerning knfd syscall interface.
> It updates write_getfd and write_getfd to accept IPv6 addresses.

Sorry for not replying to this earlier - I saw the Oct 12 post and
thought about it but didn't actually reply before getting distracted
:-(

I think this patch is unnecessary and hence not wanted.
The getfs / getfs calls should be considered legacy calls.
Adding functionality to them is not appropriate.

IPv6 addresses should be handled only via the
   /proc/net/rpc/auth.unix.ip 
interface.

Thanks,
NeilBrown
