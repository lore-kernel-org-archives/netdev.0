From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 0/2] A bugfix patchset for NetLabel
Date: Mon, 18 Dec 2006 11:24:37 -0500
Message-ID: <4586C0C5.4010502@hp.com>
References: <20061215214926.018950000@hp.com> <XMMS.LNX.4.64.0612151840370.26929@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:35280 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754227AbWLRQYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 11:24:40 -0500
To: James Morris <jmorris@namei.org>
In-Reply-To: <XMMS.LNX.4.64.0612151840370.26929@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 15 Dec 2006, paul.moore@hp.com wrote:
>  
>>This patch set fixes two bugs that were found recently when adding new CIPSOv4
>>DOI definitions.  These patches are pretty small and have been tested by a few
>>different people on several different platforms.
> 
> Applied to git://git.infradead.org/~jmorris/selinux-2.6#fixes

Thanks.

>>Please apply these for 2.6.20 and they should probably be pushed to the 2.6.19
>>stable tree as well; is there anything special I need to do for that?
> 
> I'm not sure that they qualify.
> 
> The first is a privileged operation, right?

Yes it is, you need CAP_NET_ADMIN.  I guess this probably isn't that important
for 2.6.19 then ...

> For the second, what are the implications of mapping to zero?
> 
> Also review Documentation/stable_kernel_rules.txt.

[Thanks for the pointer, didn't know that file was there]

... however, I still think this might qualify for the 2.6.19 stable kernel.
When a MLS sensitivity level or category maps to zero then whenever the NetLabel
subsystem is called to resolve the security attributes of a packet it will, in
certain configurations, return security attributes/contexts which are incorrect.

Please let me know if you think that has merit for the stable tree and I'll send
the patch to the stable mailing list.

-- 
paul moore
linux security @ hp
