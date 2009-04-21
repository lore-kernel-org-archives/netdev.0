From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] netlabel: Always remove the correct address selector
Date: Wed, 22 Apr 2009 08:43:27 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0904220843030.15873@tundra.namei.org>
References: <20090421200422.10106.24767.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	etienne.basset@numericable.fr
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421200422.10106.24767.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Apr 2009, Paul Moore wrote:

> The NetLabel address selector mechanism has a problem where it can get
> mistakenly remove the wrong selector when similar addresses are used.  The
> problem is caused when multiple addresses are configured that have different
> netmasks but the same address, e.g. 127.0.0.0/8 and 127.0.0.0/24.  This patch
> fixes the problem.
> 
> Reported-by: Etienne Basset <etienne.basset@numericable.fr>
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>
-- 
James Morris
<jmorris@namei.org>
