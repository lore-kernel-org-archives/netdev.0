From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Sat, 07 Jun 2003 23:58:25 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030607.235825.71096085.davem@redhat.com>
References: <20030606145835.3a263df8.shemminger@osdl.org>
	<20030607191522.GB3346@gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <20030607191522.GB3346@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Sat, 7 Jun 2003 15:15:22 -0400

   I would prefer to fix the drivers _before_ anything else.  i.e. Phase 2
   becomes Phase 1.
   
   These often need to be merged into 2.4 as well, and they can be applied
   to all drivers without any API changes.  The changes are separated out
   from any refcounting/sysfs stuff, and can (potentially) be considered
   and reviewed by the respective maintainers.

Have you extracted out all the init_etherdev() killings Al and
myself did so you can backport them to 2.4.x too?

If you're not going to do that, there is not much point in trying to
sync other such things back to 2.4.x as well.
