From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 19:01:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16177.13435.45921.229742@robur.slu.se>
References: <200308051340.RAA28267@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200308051340.RAA28267@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


kuznet@ms2.inr.ac.ru writes:

 > # This is a BitKeeper generated patch for the following project:
 > # Project Name: Linux kernel tree
 > # This patch format is intended for GNU patch command version 2.5 or higher.
 > # This patch includes the following deltas:
 > #	           ChangeSet	1.1613  -> 1.1614 
 > #	    net/ipv4/route.c	1.66    -> 1.67   

 Hello!

 Crap. We are back to the dst cache overflow again even with routing tables 
 loaded. Well test is now on SMP and 2.6.0-test1. Undo the min_score test 
 and give it retry? Or some new RCU stuff discover. It's current lab setup. 

 Cheers.
						--ro
 
