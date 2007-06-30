From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sat, 30 Jun 2007 17:25:07 +0200
Message-ID: <20070630152507.GB2553@xi.wantstofly.org>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <20070630120541.GA21339@srcf.ucam.org> <46866C6B.9010801@linux.intel.com> <20070630151923.GA22983@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	=?iso-8859-1?B?VPZy9ms=?= Edvin <edwintorok@gmail.com>,
	netdev@vger.kernel.org, power@bughost.org, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757968AbXF3P4i@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070630151923.GA22983@srcf.ucam.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 30, 2007 at 04:19:23PM +0100, Matthew Garrett wrote:

> I'd agree that there's a need for a state where we power down as much as 
> possible (even at the cost of functionality), but where possible it 
> would also be nice to offer a state where the mac is powered down and 
> the phy left up.

There are PHYs which can detect that someone's on the other end even
when powered down..
