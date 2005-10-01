From: Suzanne Wood <suzannew@cs.pdx.edu>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Sat, 1 Oct 2005 11:37:14 -0700 (PDT)
Message-ID: <200510011837.j91IbE01012915__18571.8561675914$1128192038$gmane$org@rastaban.cs.pdx.edu>
Cc: Robert.Olsson@data.slu.se, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please excuse this restatement of an earlier concern.

  > From suzannew Sat Oct  1 11:00:28 2005

  > With the spotlight leaving in_dev_get, we have the parallel question 
  > of in_dev_put() and __in_dev_put()  both defined with refcnt 
  > decrement, but the preceding underscore may lend itself to an
  > inadvertant pairing and refcnt inaccuracy.

Dave Miller already addressed this question in 
http://www.ussg.iu.edu/hypermail/linux/kernel/0509.3/0757.html 

  > It may not be reasonable to rename __in_dev_put for its parallel definition
  > since its current usage is with __in_dev_get_rtnl() which does not increment 
  > refcnt. 

But the following may be worth considering.

  > It is also probably good to retain the old __in_dev_get()
and deprecate it.

Thank you.
