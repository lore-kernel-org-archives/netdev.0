From: Janice M Girouard <janiceg@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 14:06:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEF66AA.3000509@us.ibm.com>
References: <OFCA1A4F38.D782F1D3-ON85256D48.000A5CED@us.ibm.com>	<200306170434.h5H4YZPZ003025@turing-police.cc.vt.edu>	<20030617090859.0ffa0ca8.shemminger@osdl.org> <20030617.090930.102574393.davem@redhat.com> <3EEF620A.40608@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
   Valdis.Kletnieks@vt.edu, Janice Girouard <girouard@us.ibm.com>,
   Daniel Stekloff
 <stekloff@us.ibm.com>, Larry Kessler <lkessler@us.ibm.com>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    From: Jeff Gazik <jgarzik@pobox.com>
    Date: Tue, 17 Jun 2003 01:46

    ...and it's been in the tree for quite a while too.  It's a shame
    people aren't taking advantage of it's obvious utility...


I'd like to hear what others believe belong in this new netlink family. 
 The two events that come to mind for this family (or netdev notified if 
that's more appropriate) are:
1) device initialization failures,
2) events that drive load balancing software.  Right now if we need to 
throttle the card, we don't send events up to indicate we have reached 
capacity.  

Possibly the first might belong in the netdev notified family, and the 
second in the netlink family, since you might want to present more than 
a two state (success/failure.. or just failure in this case) result.
-
