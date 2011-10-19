From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bluetooth: Properly clone LSM attributes to newly
 created child connections
Date: Tue, 18 Oct 2011 23:36:56 -0400 (EDT)
Message-ID: <20111018.233656.1245200653040022710.davem@davemloft.net>
References: <20111007194059.12345.13398.stgit@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: pmoore@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20111007194059.12345.13398.stgit@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 07 Oct 2011 15:40:59 -0400

> The Bluetooth stack has internal connection handlers for all of the various
> Bluetooth protocols, and unfortunately, they are currently lacking the LSM
> hooks found in the core network stack's connection handlers.  I say
> unfortunately, because this can cause problems for users who have have an
> LSM enabled and are using certain Bluetooth devices.  See one problem
> report below:
> 
>  * http://bugzilla.redhat.com/show_bug.cgi?id=741703
> 
> In order to keep things simple at this point in time, this patch fixes the
> problem by cloning the parent socket's LSM attributes to the newly created
> child socket.  If we decide we need a more elaborate LSM marking mechanism
> for Bluetooth (I somewhat doubt this) we can always revisit this decision
> in the future.
> 
> Reported-by: James M. Cape <jcape@ignore-your.tv>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied, thanks!
