From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting
 bad/custom CRC
Date: Mon, 24 Nov 2003 15:29:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124152933.1420f6cf.davem@redhat.com>
References: <3FC2931B.3070903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FC2931B.3070903@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Nov 2003 15:24:11 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Jeff, Dave, et al, please let me know if this is of interest!

I think the rx_all facility is very useful.

Secondarily, I think we should address the other features
seperately.

What I think you should do is split out the rx_all functionality
into a seperate patch, and once we've refined and integrated that
we can work one-by-one on the CRC and other bits.
