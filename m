From: Peter Bieringer <pb@bieringer.de>
Subject: Re: ip6t_LOG.c: patch killing spaces on ouput of IPv4 address on
 TUNNEL=
Date: Mon, 14 Mar 2005 20:52:27 +0100
Message-ID: <6D408DE92D49A118EA5D4FB6@worker.muc.bieringer.de>
References: <DB755B5F6CF46771B8607810@worker.muc.bieringer.de>
 <20050314080628.GE19298@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>, David Miller <davem@redhat.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20050314080628.GE19298@obroa-skai.de.gnumonks.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Monday, March 14, 2005 09:06:28 AM +0100 Harald Welte
<laforge@gnumonks.org> wrote:

> On Sat, Mar 05, 2005 at 05:01:53PM +0100, Peter Bieringer wrote:
>> Hi,
>> 
>> I'm still wondering that this was never fixed since 3 years:
> 
> Because it presumably breaks existing scripts that expect it to be in
> the broken (speced) format.

How many scripts are already parsing IPv6 log lines? Show me one, please. I
believe I'm the only one who really looked into the logs because I saw
nobody else ever claiming about the broken printout.

> I'm not particularly for or against that change... but whatever I do,
> somebody will always be complaining.  To make you happy and have someone
> else complain next time ;)

I don't believe that it is a good idea to let broken log output long time
in the kernel, especially in IPv6 world, where changes still ongoing in
current Linux kernel. How longer you wait the more will ran (perhaps) into
temporary trouble.

For all the script writers, add a module option like "broken_log_lines=yes"
;-)

Regards,
       Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>
