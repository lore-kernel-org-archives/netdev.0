From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v4 10/14] selinux: Set socket NetLabel based on
 connection endpoint
Date: Fri, 5 Sep 2008 19:08:17 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0809051908020.2526@tundra.namei.org>
References: <20080903003647.15669.45349.stgit@flek.lan> <20080903004956.15669.8029.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:39819 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255AbYIEJIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 05:08:30 -0400
In-Reply-To: <20080903004956.15669.8029.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Sep 2008, Paul Moore wrote:

> Previous work enabled the use of address based NetLabel selectors, which while
> highly useful, brought the potential for additional per-packet overhead when
> used.  This patch attempts to solve that by applying NetLabel socket labels
> when sockets are connect()'d.  This should alleviate the per-packet NetLabel
> labeling for all connected sockets (yes, it even works for connected DGRAM
> sockets).
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
> 
>  include/net/cipso_ipv4.h            |    5 ++
>  include/net/netlabel.h              |   13 ++++++
>  net/ipv4/cipso_ipv4.c               |   47 +++++++++++++++++++++
>  net/netlabel/netlabel_kapi.c        |   77 +++++++++++++++++++++++++++++++++++
>  security/selinux/hooks.c            |    4 +-
>  security/selinux/include/netlabel.h |    8 ++++
>  security/selinux/include/objsec.h   |    3 +
>  security/selinux/netlabel.c         |   48 +++++++++++++++++++++-
>  8 files changed, 201 insertions(+), 4 deletions(-)

Acked-by: James Morris <jmorris@namei.org>

-- 
James Morris
<jmorris@namei.org>
