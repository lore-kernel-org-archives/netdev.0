From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: improve domain mapping validation
Date: Sun, 19 May 2013 14:50:39 -0700 (PDT)
Message-ID: <20130519.145039.1580470275401987257.davem@davemloft.net>
References: <20130517190850.11148.51057.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	vlad.halilov@gmail.com, selinux@tycho.nsa.gov
To: pmoore@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130517190850.11148.51057.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 17 May 2013 15:08:50 -0400

> The net/netlabel/netlabel_domainhash.c:netlbl_domhsh_add() function
> does not properly validate new domain hash entries resulting in
> potential problems when an administrator attempts to add an invalid
> entry.  One such problem, as reported by Vlad Halilov, is a kernel
> BUG (found in netlabel_domainhash.c:netlbl_domhsh_audit_add()) when
> adding an IPv6 outbound mapping with a CIPSO configuration.
> 
> This patch corrects this problem by adding the necessary validation
> code to netlbl_domhsh_add() via the newly created
> netlbl_domhsh_validate() function.
> 
> Ideally this patch should also be pushed to the currently active
> -stable trees.
> 
> Reported-by: Vlad Halilov <vlad.halilov@gmail.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied and queued up for -stable, thanks.
