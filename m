From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] net-sysfs parent ref count
Date: Wed, 11 Jun 2003 23:58:23 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.235823.91336972.davem@redhat.com>
References: <20030610133508.3d0bfffc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030610133508.3d0bfffc.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 10 Jun 2003 13:35:08 -0700

   When creating network sysfs entries, we grab an extra reference to
   the parent.  Not a big deal now, since it just gets blown away on
   unregister anyway, but when kobject reference counts are used for
   release, things break.

Applied, thanks.
