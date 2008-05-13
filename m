From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] DCCP: Fix to reset the connection with Reset Code 5
	Option Error while receive invalid option
Date: Tue, 13 May 2008 11:32:19 +0100
Message-ID: <20080513103218.GA28532@gerrit.erg.abdn.ac.uk>
References: <48294E9C.4060209@cn.fujitsu.com> <20080513083033.GA11707@gerrit.erg.abdn.ac.uk> <48296623.8040405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41975 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752914AbYEMKcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 06:32:55 -0400
Content-Disposition: inline
In-Reply-To: <48296623.8040405@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Sorry for my stupid patch since I can get the test git tree.
>
There is nothing at all wrong with the patch and I apologise for the
remark, since it is not your fault not to be aware of the test tree.

That was my fault - in at least one of the 4 cases David Miller copied the
changeset over to dccp@vger. I am working with Arnaldo de Melo (the DCCP
maintainer) on a solution for this, to avoid future overlap. It is not
your issue, so sorry.

For the moment the best is to apply this patch and fix the problem in
the mainline variant of net/dccp.


> But, Is there any other way to get the git tree? I download a patch from 
> following URL:
>   
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.25.diff.gz
> I used this patch to my linux-2.6.25, there is error happend. and it has 
> compile error too.
This is possible since the snapshots are taken on the day a new release
comes out. Thanks for the notice, the outdated snapshot will be replaced.

>
> Is this patch is based on linux-2.6.25? If I want to send a patch, I  
> must create my patch base on what version of kernel?
>
The test tree tracks the netdev-2.6 kernel and only touches net/dccp. It
can be pulled from
	git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree `dccp')


Gerrit
