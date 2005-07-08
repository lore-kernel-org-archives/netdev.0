From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Thu, 07 Jul 2005 23:08:02 -0400
Message-ID: <42CDEE12.5030100@pobox.com>
References: <Pine.LNX.4.61.0507071552130.24321@resonance.WorkGroup>	<200507080106.j6816NKP022996@guinness.s2io.com> <20050707.200034.74747399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com, netdev@vger.kernel.org,
        ravinandan.arakali@neterion.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, raghavendra.koushik@neterion.com
In-Reply-To: <20050707.200034.74747399.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> If you need a PIO to complete in a specific order, you
> have to read it back.  If you need PIO operations to occur

Correct.

A PCI read is the only way to ensure that all the CPU/PCI bridge buffers 
are flushed to the device.

Whenever Arjan and I complain about "PCI posting" problems, we are 
indicating a need for additional readl() calls to ensure 
ordering/flushing.  Delaying immediately after a writel() is a classic 
PCI posting mistake.  Assuming ordering is another.

	Jeff
