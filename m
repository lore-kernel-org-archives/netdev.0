From: "James H. Cloos Jr." <cloos@jhcloos.com>
Subject: tcp socket missing from /proc/net/tcp
Date: 23 Aug 2003 15:49:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3lltk17er.fsf@lugabout.jhcloos.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm currently at 2.6 as of cset:

 tmolina@cablespeed.com|ChangeSet|20030809164017|32866

(the last one on 2003/Aug/09)

I've currently got an open ssh session to a remote box that does not
show up in /proc/net/tcp (I also checked /proc/net/tcp6 even though
the remote box doesn't do v6; it is not there either).

One possible issue is that I did an 'ifconfig sit1 down' and an
'ifconfig sit1 up' while the ssh session was up (for an unrelated
reason).  

Hmmm.  I just opened another ssh to that same box and now both show
up again in /proc/net/tcp.

v6 is copiled in, firewall stuff is a mix on in and modules.

-JimC
