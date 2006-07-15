From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 11:03:48 -0400
Message-ID: <200607151103.49142.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <20060714185915.270209000@flek.zko.hp.com> <Pine.LNX.4.64.0607142209180.19821@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cce.hp.com ([161.114.21.22]:28806 "EHLO
	ccerelrim01.cce.hp.com") by vger.kernel.org with ESMTP
	id S1946057AbWGOPD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 11:03:57 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607142209180.19821@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 July 2006 10:18 pm, James Morris wrote:
>
> If you're in a permanent cleanup phase, why bother clearing all of these
> global variables and using temporary pointers?
>
> Why not just simply free each entry?  The way this is coded makes it seem
> like you're unsure about the safety of the code.
>
> e.g. what could it possibly matter at this stage whether cipso_v4_cache is
> NULL or not?
>
> I think I asked this some time ago: what are the lifetime rules for this
> code as a loadable module?  What if you arbitrarily rmmod it?
>

The answer to all of your comments in this email is that these appear to be 
fragments from earlier thoughts about trying to make this code a loadable 
module.  Upon further reflection I realized that it probably doesn't make 
much sense to have this code as a module for much of the same reason that 
SELinux isn't setup as a loadable module.

As you have progressed through the patchset I'm sure you've realized by now 
this code is not intended to function as a module.  I'll clean these 
leftovers up for the next version of the patchset.

-- 
paul moore
linux security @ hp
