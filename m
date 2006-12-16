From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/2] A bugfix patchset for NetLabel
Date: Fri, 15 Dec 2006 20:19:56 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0612151840370.26929@d.namei>
References: <20061215214926.018950000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:46340 "EHLO
	mail6.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030526AbWLPB0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 20:26:38 -0500
To: paul.moore@hp.com
In-Reply-To: <20061215214926.018950000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Dec 2006, paul.moore@hp.com wrote:

> This patch set fixes two bugs that were found recently when adding new CIPSOv4
> DOI definitions.  These patches are pretty small and have been tested by a few
> different people on several different platforms.

Applied to git://git.infradead.org/~jmorris/selinux-2.6#fixes

> Please apply these for 2.6.20 and they should probably be pushed to the 2.6.19
> stable tree as well; is there anything special I need to do for that?

I'm not sure that they qualify.

The first is a privileged operation, right?

For the second, what are the implications of mapping to zero?


Also review Documentation/stable_kernel_rules.txt.





-- 
James Morris
<jmorris@namei.org>
