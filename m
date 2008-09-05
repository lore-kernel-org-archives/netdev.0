From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v4 04/14] selinux: Fix missing calls to
 netlbl_skbuff_err()
Date: Fri, 5 Sep 2008 18:55:48 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0809051855300.2526@tundra.namei.org>
References: <20080903003647.15669.45349.stgit@flek.lan> <20080903004908.15669.36176.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080903004908.15669.36176.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Sep 2008, Paul Moore wrote:

> At some point I think I messed up and dropped the calls to netlbl_skbuff_err()
> which are necessary for CIPSO to send error notifications to remote systems.
> This patch re-introduces the error handling calls into the SELinux code.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
> 
>  include/net/netlabel.h              |    6 ++++--
>  net/netlabel/netlabel_kapi.c        |    5 +++--
>  security/selinux/hooks.c            |   19 +++++++++++++++----
>  security/selinux/include/netlabel.h |    9 +++++++++
>  security/selinux/netlabel.c         |   20 +++++++++++++++++++-
>  5 files changed, 50 insertions(+), 9 deletions(-)
> 

Acked-by: James Morris <jmorris@namei.org>

-- 
James Morris
<jmorris@namei.org>
