From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 10:32:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.103234.116374169.davem@redhat.com>
References: <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
	<20030610.084940.74727904.davem@redhat.com>
	<Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 13:33:01 -0400 (EDT)

   On Tue, 10 Jun 2003, David S. Miller wrote:
   
   > When packet (more specifically, software interrupt) processing
   > reaches a certain level, we offload the work into process context.
   
   That sounds good.

Adjust the nice value of the ksoftirqd tasks, that's the
only thing available.

But your problem has to do with all the PIO accesses, that
absolutely kills the machine.
