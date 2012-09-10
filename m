From: David Miller <davem@davemloft.net>
Subject: Re: Endianess bug fix for sierra_net
Date: Mon, 10 Sep 2012 15:06:10 -0400 (EDT)
Message-ID: <20120910.150610.41894888381057478.davem@davemloft.net>
References: <20120907221402.GJ15650@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, bjorn@mork.no,
	linux@sierrawireless.com, netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120907221402.GJ15650@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Date: Fri, 7 Sep 2012 18:14:02 -0400

> I discovered I couldn't get sierra_net to work on a powerpc.  Turns out
> the firmware attribute check assumes the system is little endian and
> hence fails because the attributes is a 16 bit value.
> 
> Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>

Applied and queued up for -stable, thanks.
