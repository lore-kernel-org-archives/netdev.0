From: Andrew Morton <akpm@digeo.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPUload
Date: Tue, 17 Sep 2002 12:53:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D878841.EB580DE9@digeo.com>
References: <72A87F7160C0994D8C5A36E2FDC227F502B3E70D@txnexc01.americas.cpqcorp.net> <3D878675.3000403@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 
> ...
> Also, a further question:  do you have access to the slave struct
> net_device?  If so, just test netif_carrier_ok(slave_dev) and avoid all
> that ioctl calling if it returns non-zero.

Make that "avoid all that ioctl calling from interrupt context", which
is a bug.  Of the box-killing variety ;)
