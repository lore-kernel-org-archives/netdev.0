From: Tomasz Torcz <zdzichu@irc.pl>
Subject: Re: Device naming for wireless NICs...
Date: Thu, 11 Mar 2004 17:36:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040311163657.GB28234@irc.pl>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com> <20040311024816.GC3738@jm.kir.nu> <404FD6BC.7090409@pobox.com> <20040311031709.GC3782@jm.kir.nu> <405093A7.90209@linux.co.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <405093A7.90209@linux.co.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 11, 2004 at 10:28:23AM -0600, James Ketrenos wrote:
> I don't mind adding a module parameter to change the default name (if that 
> is the standard practice), but thought I'd see what others thing rather 
> than just going off and doing something random.

 This could be handled by nameif in userspace.
 
> Is there a technical or ease of use reason switching away from ethX?  My 
> thinking in keeping it eth was that it then represents a greater chance of 
> "just working" with most networking scripts and utilities that may assume 
> ethX is the interface name.

 I personally find them broken. I had to remove checking the name from
ethtool to make it work. Ethtool checks for 'eth' or 'usb' in name,
which do not work with my e1000 renamed to 'ep0'.

-- 
Tomasz Torcz                Only gods can safely risk perfection,     
zdzichu@irc.-nie.spam-.pl     it's a dangerous thing for a man.  -- Alia
