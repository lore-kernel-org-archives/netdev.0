From: Tomasz Torcz <zdzichu@irc.pl>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Tue, 1 Mar 2005 21:46:15 +0100
Message-ID: <20050301204615.GC15329@irc.pl>
References: <200502270928.44402.Info@Quantum-Sci.com> <200502271410.39611.Info@quantum-sci.com> <20050227133517.578884df.davem@davemloft.net> <200503011207.34029.vda@port.imtp.ilyichevsk.odessa.ua> <422497BA.9090606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <422497BA.9090606@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2005 at 11:26:34AM -0500, Jeff Garzik wrote:
> Just write sane firewall rules that don't allow incoming.

 Isn't this thread about non-working stateful firewalling? Specifically
situation where -m state --state RELATED or ESTABLISHED isn't allowin
any packets because there is no connection tracking? Without allowing
incoming packets there could be no 2-way communication (for UDP at
least).

-- 
Tomasz Torcz               "Never underestimate the bandwidth of a station
zdzichu@irc.-nie.spam-.pl    wagon filled with backup tapes." -- Jim Gray
