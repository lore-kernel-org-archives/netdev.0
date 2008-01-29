From: Paul Moore <paul.moore@hp.com>
Subject: [GIT PULL] pull request for lblnet-2.6_testing
Date: Tue, 29 Jan 2008 10:09:31 -0500
Message-ID: <200801291009.32056.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

I've just rebased the lblnet-2.6_testing tree against Linus' latest 
which already includes DaveM's net-2.6.25 tree so there shouldn't be 
any collisions with the core networking bits.  Other than minor changes 
needed to merge cleanly with the current linux-2.6 tree there have been 
no changes to the labeled networking patches since they were last 
posted.  The git tree can be found here:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing

In the interest of full disclosure, I was not able to test this tree as 
there are a few compile errors in the drivers area which are preventing 
me from getting a kernel built.  However, all of the relevant areas 
(security/selinux, net/netlabel, net/netfilter, net/xfrm, net/ipv4, 
net/ipv6) compiled without issue.  I will continue to try and get a 
kernel compiled but I thought getting this out in a reasonable 
timeframe to minimize merge issues was a better decision.  Thse patches 
applied to 2.6.24 do compile, boot, and run without any known 
regressions.

-- 
paul moore
linux security @ hp
