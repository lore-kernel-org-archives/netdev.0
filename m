From: ookhoi@humilis.net
Subject: why does netfilter make upload very slow? (was: Re: e1000 -> 82540EM on linux 2.6.0-test[45] very slow in one direction)
Date: Wed, 8 Oct 2003 15:13:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008131320.GD16964@favonius>
Reply-To: ookhoi@humilis.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ookhoi wrote (ao):
# Ookhoi wrote (ao):
# > Florian Zwoch wrote (ao):
# > > issue seems to partly solved. the e1000 driver seems to be ok!
# > > i reconfigured my kernel and intentionally left out netfilter options. 
# > > after that my network performance was back to normal.
# > > 
# > > netfilter was only compiled in the kernel. it was not used with any rules!
# > > 
# > > so my wild guess would be that something with the netfilter code (i am 
# > > not 100% sure it was netfilter.. _maybe_ it was some small odd kernel 
# > > option i accidently enabled/disabled) is broken since test3 (again 
# > > uncertified. but i firstly noticed this switching from test3 to test4).
# 
# > I have netfilter enabled, and will try another -test6 kernel with
# > netfilter not compiled in to see if that indeed makes a difference.
# 
# I can confirm now that disabling netfilter in 2.6.0-test6 makes the nic
# perform oke wrt upload.
# I (just like Florian) had no iptables rules active in the former
# 2.6.0-test6 kernel, but netfilter was compiled in.

Would somebody like to explain why netfilter (in kernel, but not in use)
makes upload go very slow? I am by no means a network guru, but eager to
learn :-)
