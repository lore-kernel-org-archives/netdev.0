From: Andrew Morton <akpm@digeo.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:27:07 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030616152707.58da808c.akpm@digeo.com>
References: <3EEE28DE.6040808@us.ibm.com>
	<20030616.133841.35533284.davem@redhat.com>
	<20030616205342.GH30400@wotan.suse.de>
	<20030616.135124.71580008.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, janiceg@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, stekloff@us.ibm.com, girouard@us.ibm.com,
	lkessler@us.ibm.com, kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030616.135124.71580008.davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> wrote:
>
>    From: Andi Kleen <ak@suse.de>
>    Date: Mon, 16 Jun 2003 22:53:42 +0200
>    
>    Why? It will make supporting netconsole easier which has to be careful
>    to never recurse in the network driver.
> 
> printk can check this

Actually it already does, to cover the case where an interrupt handler calls
printk while process-context code is performing a printk.

The nested printk will squirt the message into the log buffer and the
"outer" code will display it.
