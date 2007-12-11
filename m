From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: net-2.6.25 being rebased...
Date: Tue, 11 Dec 2007 22:35:40 +0100
Message-ID: <20071211213540.GA30706@electric-eye.fr.zoreil.com>
References: <20071211.092638.148402625.davem@davemloft.net> <20071211.115619.199600421.davem@davemloft.net> <1197407100.4911.150.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44960 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751906AbXLKVmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 16:42:14 -0500
Content-Disposition: inline
In-Reply-To: <1197407100.4911.150.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> :
[...]
> I have an earlier unmodified git repository of net-2.6.25.
> Does anyone know the appropriate git commands to resync
> to the rebased content?
> 
> $ git branch
> * master
> $ git-pull
> [...]
> Automatic merge failed; fix conflicts and then commit the result.

Assuming taht you initially cloned from davem's repo, your .git/config
could contain something along the lines of:

 [remote "origin"]
         url = git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
         fetch = +refs/heads/*:refs/remotes/origin/*

(the "+" will update even non fast-forwarding branches)

Then:

$ git fetch origin
$ git fetch -u remotes/origin/master:master

You may then reset --hard to wipe out any leftover file.

If you cloned from somewhere else, replace "origin" with the label of
your choice to automate the process.

-- 
Ueimor
