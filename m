From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] ip_nat_ftp - manip at the right place
Date: Sun, 12 Sep 2004 17:03:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912170323.65eadc38.davem@davemloft.net>
References: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@oss.sgi.com, rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Sep 2004 10:53:53 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	This is a resend/resync for v2.6.9-rc1-bk17: change the
> way the ip_nat_ftp helper manipulates the packets:
> 
> - no manips => no fixup
> 
> - check the direction, do manip once and at the same time when the
> headers are changed
> 
> 	This is needed mostly for IPVS setups and I hope we do not
> create troubles for other setups or FTP software.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Harald and/or Rusty, please ACK/NACK this for me.

Thanks.
