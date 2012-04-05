From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: [PATCH 1/1] bonding: properly unset current_arp_slave on slave
 link up
Date: Thu, 5 Apr 2012 14:06:14 -0400
Message-ID: <20120405180614.GB11165@quad.redhat.com>
References: <20120405134743.GB16870@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120405134743.GB16870@darkmag.usersys.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 05, 2012 at 03:47:43PM +0200, Veaceslav Falico wrote:
> When a slave comes up, we're unsetting the current_arp_slave without
> removing active flags from it, which can lead to situations where we have
> more than one slave with active flags in active-backup mode.
> 
> To avoid this situation we must remove the active flags from a slave before
> removing it as a current_arp_slave.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> 

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
