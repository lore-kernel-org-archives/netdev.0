From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v2 1/2] NetLabel: Allow passing the LSM domain as a
 shared pointer
Date: Fri, 11 Apr 2008 08:06:04 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0804110805370.1313@us.intercode.com.au>
References: <20080409204936.26774.55254.stgit@flek.lan>
 <20080409205039.26774.50884.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080409205039.26774.50884.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Apr 2008, Paul Moore wrote:

> Smack doesn't have the need to create a private copy of the LSM "domain" when
> setting NetLabel security attributes like SELinux, however, the current
> NetLabel code requires a private copy of the LSM "domain".  This patches fixes
> that by letting the LSM determine how it wants to pass the domain value.
> 
>  * NETLBL_SECATTR_DOMAIN_CPY
>    The current behavior, NetLabel assumes that the domain value is a copy and
>    frees it when done
> 
>  * NETLBL_SECATTR_DOMAIN
>    New, Smack-friendly behavior, NetLabel assumes that the domain value is a
>    reference to a string managed by the LSM and does not free it when done
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
