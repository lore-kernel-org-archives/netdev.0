From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.71] Fix module owner for bonding driver
Date: Mon, 16 Jun 2003 16:10:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.161050.85423902.davem@redhat.com>
References: <20030616154251.28c3e3ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ctindel@users.sourceforge.net, fubar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030616154251.28c3e3ee.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 16 Jun 2003 15:42:51 -0700

   The bonding driver does explicit MOD_INC/DEC even though it does a
   SET_MODULE_OWNER.  So it doesn't changes module use counts on
   open/close on 2.5 when it shouldn't.  It also has a /proc entry
   which does not affect the module use counts when it should.
   
Applied, thanks Stephen.

   Suggestion: the /proc interface could/should be converted to seq_file.
   Volunteers? Janitor project?
   
There is a bonding maintainer, maybe that'd be the best bet :-)
