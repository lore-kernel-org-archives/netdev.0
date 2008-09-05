From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v4 03/14] selinux: Fix a problem in
 security_netlbl_sid_to_secattr()
Date: Fri, 5 Sep 2008 18:53:11 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0809051852460.2526@tundra.namei.org>
References: <20080903003647.15669.45349.stgit@flek.lan> <20080903004901.15669.37418.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080903004901.15669.37418.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Sep 2008, Paul Moore wrote:

> Currently when SELinux fails to allocate memory in
> security_netlbl_sid_to_secattr() the NetLabel LSM domain field is set to
> NULL which triggers the default NetLabel LSM domain mapping which may not
> always be the desired mapping.  This patch fixes this by returning an error
> when the kernel is unable to allocate memory.  This could result in more
> failures on a system with heavy memory pressure but it is the "correct"
> thing to do.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
