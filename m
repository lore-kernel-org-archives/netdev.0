From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Fri, 23 Apr 2004 12:31:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87smevrno9.fsf@deneb.enyo.de>
References: <Pine.LNX.4.44.0404221030240.2738-100000@paix.pilosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: alex@pilosoft.com
In-Reply-To: <Pine.LNX.4.44.0404221030240.2738-100000@paix.pilosoft.com> (alex@pilosoft.com's
 message of "Thu, 22 Apr 2004 10:37:42 -0400 (EDT)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

alex@pilosoft.com writes:

> Not quite. With a SYN you have to respond with exactly the same sequence 
> number as attacking host in order to establish connection. With RST, your 
> sequence number needs to be +- rwin in order to kill the connection. That 
> significantly reduces search space.

Don't forget that you can tear down a connection by sending a SYN in
the correct window as well.

-- 
Current mail filters: many dial-up/DSL/cable modem hosts, and the
following domains: atlas.cz, bigpond.com, postino.it, tiscali.co.uk,
tiscali.cz, tiscali.it, voila.fr.
