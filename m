From: Al Boldi <a1426z@gawab.com>
Subject: Re: TCP throttling
Date: Tue, 20 Sep 2005 06:54:23 +0300
Message-ID: <200509200654.23703.a1426z@gawab.com>
References: <200509190646.57579.a1426z@gawab.com> <20050919112008.17ad14f5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050919112008.17ad14f5@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> You probably need to increase the maximum socket buffer
> sizes.  Linux defaults are conservative to avoid running
> servers out of memory.
>
> http://www.psc.edu/networking/projects/tcptune/#Linux

Thanks for the great link! It kept me up all night.

I managed to crash the server running out of memory.  Don't ask what numbers 
I used, I just went overboard.  I played with these numbers before, but 
never imagined that their scale would be in the millions.

Could you suggest sane values for 2.4/2.6 on a 100mbit link?

Thanks!

--
Al

