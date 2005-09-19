From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP throttling
Date: Mon, 19 Sep 2005 11:20:08 -0700
Message-ID: <20050919112008.17ad14f5@dxpl.pdx.osdl.net>
References: <200509190646.57579.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Al Boldi <a1426z@gawab.com>
In-Reply-To: <200509190646.57579.a1426z@gawab.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You probably need to increase the maximum socket buffer
sizes.  Linux defaults are conservative to avoid running
servers out of memory.

http://www.psc.edu/networking/projects/tcptune/#Linux
