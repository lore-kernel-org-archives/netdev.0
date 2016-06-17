From: David Miller <davem@davemloft.net>
Subject: Re: PATCH 1/1] AX.25: Close socket connection on session completion
Date: Fri, 17 Jun 2016 11:33:19 -0700 (PDT)
Message-ID: <20160617.113319.2120711643214980498.davem@davemloft.net>
References: <20160616094230.1d023d0b@brox.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: basil@pacabunga.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616094230.1d023d0b@brox.localnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Basil Gunn <basil@pacabunga.com>
Date: Thu, 16 Jun 2016 09:42:30 -0700

> A socket connection made in ax.25 is not closed when session is
> completed.  The heartbeat timer is stopped prematurely and this is
> where the socket gets closed. Allow heatbeat timer to run to close
> socket. Symptom occurs in kernels >= 4.2.0
> 
> Originally sent 6/15/2016. Resend with distribution list matching
> scripts/maintainer.pl output.
> 
> Signed-off-by: Basil Gunn <basil@pacabunga.com>

What changed in 4.2.x that broke this?
