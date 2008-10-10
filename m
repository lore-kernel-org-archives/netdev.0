From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v7 01/17] netlabel: Fix some sparse warnings
Date: Sat, 11 Oct 2008 08:45:56 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0810110845340.2822@tundra.namei.org>
References: <20081006191516.15686.80823.stgit@flek.lan> <20081006191948.15686.24567.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20081006191948.15686.24567.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Oct 2008, Paul Moore wrote:

> Fix a few sparse warnings.  One dealt with a RCU lock being held on error,
> another dealt with an improper type caused by a signed/unsigned mixup while
> the rest appeared to be caused by using rcu_dereference() in a
> list_for_each_entry_rcu() call.  The latter probably isn't a big deal, but
> I derive a certain pleasure from knowing that the net/netlabel is nice and
> clean.
> 
> Thanks to James Morris for pointing out the issues and demonstrating how
> to run sparse.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Reviewed-by: James Morris <jmorris@namei.org>

-- 
James Morris
<jmorris@namei.org>
