From: Janos Farkas <jf-ml-k1-1087813225@lk8rp.mail.xeon.eu.org>
Subject: Re: 2.6.11-rc2 TCP ignores PMTU ICMP (Re: Linux 2.6.11-rc2)
Date: Thu, 27 Jan 2005 21:00:56 +0100
Message-ID: <priv$1106854599.koan@lk8rp.mail.xeon.eu.org>
References: <200501232251.42394.david-b@pacbell.net> <200501251054.37053.david-b@pacbell.net> <priv$1106815487.koan@shadow.banki.hu> <200501271128.48411.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ford <david+challenge-response@blue-labs.org>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
Content-Disposition: inline
In-Reply-To: <200501271128.48411.david-b@pacbell.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2005-01-27 at 11:28:48, David Brownell wrote:
> > Indeed, I had to shuffle my machines around a bit to get a proof that
> > something is broken, but now I can confirm the above with a connection
> > to cvs.sourceforge.net:
> 
> Thanks for confirming it wasn't just me ... I confess I'm a bit
> surprised more folk haven't reported this yet! 
> 
> Your symptoms are exactly like those I saw, just with a different
> mission-critical application:  CVS, not SMTP.  Did you happen to
> notice whether CVS pulls worked, when pushes (like this) failed?

I'm familiar with symptoms arising from various stochastic/assymetric
networking problems with larger frames, I had cable :)  This was a pull
(update), BTW, CVS can send more data in this situation too.  But it
turned painfully obvious when trying to send mail to LK via SMTP.  Oh,
but while plain rc2 may have this problem, this particular endpoint had
rc2-bk3 running.  I also chose to set the ethernet MTU to 1492 as an
easy workaround...

-- 
Janos | romfs is at http://romfs.sourceforge.net/ | Don't talk about silence.
