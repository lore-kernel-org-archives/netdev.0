From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Labeled networking patches for 2.6.30
Date: Fri, 27 Mar 2009 14:58:40 -0700 (PDT)
Message-ID: <20090327.145840.218658417.davem@davemloft.net>
References: <20090327205520.17777.32557.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, casey@schaufler-ca.com,
	etienne.basset@numericable.fr
To: paul.moore@hp.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090327205520.17777.32557.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 27 Mar 2009 17:10:20 -0400

> This patchset wraps up all the new labeled networking bits for 2.6.30.  This
> is mostly a fixup/cleanup release with the main focus being to correct the
> TCP labeling of both SELinux and Smack; expect some of this to get backported
> to the -stable trees but there will need to be a bit of rework first so it
> may take a few weeks for that to happen.  Other than the TCP issue there is a
> new Smack feature to configure CIPSO aware hosts in "/smack/netlabel" which
> should make the host/network label configuration much more flexible.  The last
> change is to get rid of the security_socket_post_accept() hook which isn't
> currently being used by anything in-tree and seems to act as a magnet for
> bad ideas; if things change we can always add it back later.

Is James Morris going to take this stuff?  Just curious...
