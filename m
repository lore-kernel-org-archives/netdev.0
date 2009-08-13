From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] security: introducing security_request_module
Date: Thu, 13 Aug 2009 09:03:06 -0500
Message-ID: <20090813140306.GC30731@us.ibm.com>
References: <20090813134451.29186.41664.stgit@paris.rdu.redhat.com> <20090813134457.29186.7182.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	sds@tycho.nsa.gov, davem@davemloft.net,
	shemminger@linux-foundation.org, kees@ubuntu.com,
	morgan@kernel.org, casey@schaufler-ca.com, dwalsh@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48781 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbZHMOLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 10:11:21 -0400
Content-Disposition: inline
In-Reply-To: <20090813134457.29186.7182.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric Paris (eparis@redhat.com):
> Calling request_module() will trigger a userspace upcall which will load a
> new module into the kernel.  This can be a dangerous event if the process
> able to trigger request_module() is able to control either the modprobe
> binary or the module binary.  This patch adds a new security hook to
> request_module() which can be used by an LSM to control a processes ability
> to call request_module().

Is there a specific case in which you'd want to deny this ability
from a real task?

-serge
