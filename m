From: Suzanne Wood <suzannew@cs.pdx.edu>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Thu, 29 Sep 2005 16:39:57 -0700 (PDT)
Message-ID: <200509292339.j8TNdvKc019657__29490.5242896222$1128037452$gmane$org@rastaban.cs.pdx.edu>
Cc: Robert.Olsson@data.slu.se, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  > From suzannew Thu Sep 29 16:30:28 2005

  > > From: Herbert Xu 30 Sep 2005 07:28

  > > BTW, could you please move the rcu_dereference in in_dev_get()
  > > into the if clause? The barrier is not needed when ip_ptr is
  > > NULL.

  > The trouble with that may be that there are three events, the
  > dereference, the assignment, and the conditional test.  The
  > rcu_dereference() is meant to assure deferred destruction
  > throughout.

Sorry, I was thinking in terms of the rcu_read_lock, so this is misstated.
