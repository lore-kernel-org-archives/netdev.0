From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Fwd: [Bug 3397] New: Network connections hang going through an OpenBSD
 firewall]
Date: Tue, 14 Sep 2004 14:00:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41475BEA.2030803@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vuksan-hoforums@veus.hr
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can you reproduce on the latest kernel, please?
Is the OpenBSD mangling the packet in any way?

Can anyone tell me if this smells like something
recently fixed (MTU issues)? Doesn't sound like
the windowscaling problem but could be related.


thanks,
Nivedita


-------- Original Message --------
Subject: [Bug 3397] New: Network connections hang going through an
OpenBSD firewall
Date: Tue, 14 Sep 2004 09:38:24 -0700
From: bugme-daemon@osdl.org
To: niv@us.ibm.com

http://bugme.osdl.org/show_bug.cgi?id=3397

            Summary: Network connections hang going through an OpenBSD
                     firewall
     Kernel Version: 2.6.6+
             Status: NEW
           Severity: blocking
              Owner: niv@us.ibm.com
          Submitter: vuksan-hoforums@veus.hr


Distribution: Fedora Core 2, Gentoo
Hardware Environment: All
Software Environment: All
Problem Description:
We have seen a number of issues with people accessing our website
http://www.cs.unm.edu/ using kernels 2.6.6+. Doing some network sniffing
we can
see that data request is received by the web server and the web server
responds
however after certain amount of bytes it simply stops.

I have played with MTU sizes and if Ethereal is to be believed the transfer
stops after MTU + 77 bytes.

This has been reported to us by a number of different people running
different
distributions ie. Fedora Core 2, Gentoo. For example 2.6.5 kernel that comes
with FC2 works. Secure IMAP and Secure POP don't seem to work either
using 2.6.6+.

What is even stranger is that SSH connections don't exhibit this kind of a
problem ie. you can SSH withouth a hitch.

A data point is that we are using transparent (in-line) OpenBSD firewall
with
Packetfilter.


Steps to reproduce:

Boot into 2.6.6+ kernel try pulling up http://www.cs.unm.edu/ through a web
browser. It won't show up. Boot into a 2.6.5 and below and the page will
show up.

Any clues will be appreciated.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
