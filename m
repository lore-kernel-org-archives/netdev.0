From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BUG] drivers/net/ioc3_eth.c in 2.5
Date: Mon, 09 Jun 2003 10:09:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.100913.67895069.davem@redhat.com>
References: <20030606161658.1f01b8f9.shemminger@osdl.org>
	<20030607.013010.116359540.davem@redhat.com>
	<20030609101018.0ca2e1f9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@oss.sgi.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030609101018.0ca2e1f9.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 9 Jun 2003 10:10:18 -0700
   
   pci_unregister_driver does the iteration but not the net device
   cleanup.
   
You're absolutely right.
