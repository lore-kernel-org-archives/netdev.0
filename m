From: "David S. Miller" <davem@redhat.com>
Subject: Re: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 14:54:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215145422.58a78551.davem@redhat.com>
References: <3FDE13AE.3050402@candelatech.com>
	<20031215141729.15387fc1.davem@redhat.com>
	<3FDE39E3.4000408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FDE39E3.4000408@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2003 14:46:59 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Maybe the stats-polling code in the driver could do the necessary subtraction
> to remove the FCS from the results (ie, subtract (packets-since-last-sample * 4) bytes.

The whole reason to use the chip internally computed stats is to avoid
having to do "stats->foo++" at all, your suggestion basically eliminates
this purpose.
