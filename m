From: Werner Almesberger <wa@almesberger.net>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.45
Date: Sat, 2 Nov 2002 23:23:08 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021102232308.A4482@almesberger.net>
References: <OFB7772DA2.01708E94-ON87256C65.006EDAE7@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFB7772DA2.01708E94-ON87256C65.006EDAE7@boulder.ibm.com>; from kumarkr@us.ibm.com on Sat, Nov 02, 2002 at 01:13:22PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ Cc: trimmed ]

Krishna Kumar wrote:
> userspace -  what happens when signals (KILL) are sent to that process ?

They die, as they should.

> We don't want the home agent functionality to stop in that case, even
> if it is a system admin error.

So what makes the home agent so much more important than, say, named,
pppd, gated, portmap, inetd, sendmail, sshd, etc. ?

A much more common admin mistake would be to reboot the wrong box, or
to disconnect the wrong cable, and you're powerless against this too.

If all else fails, add this to ~root/.bashrc:
alias kill='echo "Sorry, you'\''re too dumb for this"; false'
:-)

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
