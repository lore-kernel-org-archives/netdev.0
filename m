From: Troy Wilson <tcw@tempest.prismnet.com>
Subject: SPECWeb99 Data -- tcp-wakeups
Date: Wed, 25 Sep 2002 10:47:53 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209251547.g8PFlsrR013807@tempest.prismnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   lse-tech@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   ********************************************************************
   *  SPEC(tm) and the benchmark name SPECweb(tm) are registered      *
   *  trademarks of the Standard Performance Evaluation Corporation.  *
   *  This benchmarking was performed for research purposes only,     *
   *  and is non-compliant, with the following deviations from the    *
   *  rules -                                                         *
   *                                                                  *
   *    1 - It was run on hardware that does not meed the SPEC        *
   *        availability-to-the-public criteria.  The machine is      *
   *        an engineering sample.                                    *
   *                                                                  *
   *    2 - access_log wasn't kept for full accounting.  It was       *
   *        being written, but deleted every 200 seconds.             *
   ********************************************************************

  I've done some testing with SPECWeb99 on 2.5.35 mm1 with and without 
the tcp-wakeups patch backed out.  The addition of tcp-wakeups makes a 2%
improvement in performance.

                           mm1              mm1 without tcp-wakeup
                         -----------------------------------------
Simultaneous connections   3049             2982


  The system is an 8-way, 900MHz, Profusion-based P3 box with 32GB memory.
It's connected to 16 SPECWeb client machines via 4 e1000 gigabit adapters.
I'm using Apache 2.0.36 as the webserver.

- Troy
