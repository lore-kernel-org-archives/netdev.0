From: "Wolfpaw - Dale Corse" <admin@wolfpaw.net>
Subject: RE: Linux 2.4.27 SECURITY BUG - TCP Local andREMOTE(verified)Denial of Service Attack
Date: Sun, 12 Sep 2004 13:18:46 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002801c498fd$536d33f0$0200a8c0@wolf>
References: <02bd01c498fc$fe1954b0$0300a8c0@s>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <peter@mysql.com>, <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <02bd01c498fc$fe1954b0$0300a8c0@s>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Sul, 2004-09-12 at 19:40, Wolfpaw - Dale Corse wrote:
> > This bug also exists with Apache, the default config of SSH, and
> > anything controlled by inetd. This is the vast majority of popular 
> > services on a regular internet server.. That is bad, no?
> 
> I'm unable to duplicate any such problems with xinetd, or 
> with thttpd, or with apache. Apache will wait a short time 
> then timeout connections if you've configured it right. If 
> you can continue making millions of connections a second you 
> can DoS the server the other end, not exactly new news. The 
> alternative is that you have an infinite number of running 
> services and you run out of memory instead.

Slackware doesn't use xinetd, but rather inetd. Is inetd an
old version which is no longer maintained? Apache, it didn't
kill, but slowed it down quite a bit. You are correct for sure
on that point though, there is nothing that can be done about
connection floods.

> Thats a high level property of any protocol which allows 
> commitment of resource without being able to do the security 
> authentication first. Its very hard to create ones that don't 
> however, thus most devices in life (eg your telephone) have 
> this form or DoS attack.

Very true :(

> My sshd also doesn't show this problem and the manual page 
> indicates it has a 120 second grace timeout for authentication.
> 
> The sshd manual page says:
> 
>      Gives the grace time for clients to authenticate themselves
>              (default 120 seconds).

Again - likely a connection flooding DoS there.. Which can't be helped
Unless you use ipchains to limit the amount of connections per ip
address.

Thanks for the reply :)
D.
