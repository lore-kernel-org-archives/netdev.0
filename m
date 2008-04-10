From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v2 2/2] LSM: Make the Labeled IPsec hooks more stack
 friendly
Date: Fri, 11 Apr 2008 08:08:50 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0804110808080.1313@us.intercode.com.au>
References: <20080409204936.26774.55254.stgit@flek.lan>
 <20080409205044.26774.12364.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080409205044.26774.12364.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Apr 2008, Paul Moore wrote:

> The xfrm_get_policy() and xfrm_add_pol_expire() put some rather large structs
> on the stack to work around the LSM API.  This patch attempts to fix that
> problem by changing the LSM API to require only the relevant "security"
> pointers instead of the entire SPD entry; we do this for all of the
> security_xfrm_policy*() functions to keep things consistent.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>

-- 
James Morris
<jmorris@namei.org>
