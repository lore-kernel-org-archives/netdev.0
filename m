From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 13:51:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.135124.71580008.davem@redhat.com>
References: <3EEE28DE.6040808@us.ibm.com>
	<20030616.133841.35533284.davem@redhat.com>
	<20030616205342.GH30400@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: janiceg@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   stekloff@us.ibm.com, girouard@us.ibm.com, lkessler@us.ibm.com,
   kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030616205342.GH30400@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Mon, 16 Jun 2003 22:53:42 +0200
   
   Why? It will make supporting netconsole easier which has to be careful
   to never recurse in the network driver.

printk can check this
