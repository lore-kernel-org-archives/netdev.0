From: "David S. Miller" <davem@redhat.com>
Subject: Re: [rfc] more atm cleanup
Date: Tue, 24 Jun 2003 16:31:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624.163156.35039084.davem@redhat.com>
References: <200306240353.h5O3r1sG025541@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
In-Reply-To: <200306240353.h5O3r1sG025541@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: chas williams <chas@cmf.nrl.navy.mil>
   Date: Mon, 23 Jun 2003 23:50:54 -0400

   here's a couple of changes, in short, protect/setup br2684 and pppoatm
   ioctl's with a mutex, get rid of sleep in vcc and just use sock->sleep,
   replace wake_up() with sk_state_change and sk_data_ready (sk_write_space
   needs some thinking so we have one wake_up not converted).  vcc->callback()
   also goes away in favor of sk_state_change().
   
This one looks good to me.
