From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Tue, 6 Jul 2004 14:02:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706140256.4a00251c.davem@redhat.com>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: util@deuroconsult.ro, netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 1 Jul 2004 11:33:12 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch updates the network emulation packet scheduler.
> 	* name changed from delay to netem since it does more than just delay
> 	* Catalin's merged code to do packet reordering
> 	* uses a socket queue's directly rather than layering on qdisc(fifo)
> 	  because this is used in performance tests.
> 	* adds placeholder in API for future enhancements (rate and duplicate).
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
