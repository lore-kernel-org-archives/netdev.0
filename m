From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2.6] ip_nat_ftp - manip at the right place
Date: Thu, 16 Sep 2004 08:13:20 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095286400.1940.8.camel@bach>
References: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
	 <20040913163002.35aae28c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040913163002.35aae28c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-14 at 09:30, David S. Miller wrote:
> On Sat, 11 Sep 2004 10:53:53 +0300 (EEST)
> Julian Anastasov <ja@ssi.bg> wrote:
> 
> > 	This is a resend/resync for v2.6.9-rc1-bk17: change the
> > way the ip_nat_ftp helper manipulates the packets:
> > 
> > - no manips => no fixup
> > 
> > - check the direction, do manip once and at the same time when the
> > headers are changed
> > 
> > 	This is needed mostly for IPVS setups and I hope we do not
> > create troubles for other setups or FTP software.
> 
> I'm still waiting for ACK/NACK of this.  I know Rusty is travelling
> and Harald is probably busy too, so I know the delay in response is not
> because these guys are slackers :-)

Mine is because I'm porting the existing FTP testsuite to nfsim, so I
can test the patch doesn't break anything.  As far as I can tell, this
change isn't vital, so I'm not losing sleep to do it...

Thanks,
Rusty.
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell
