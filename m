From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH 2.6.X] SIOCSIFNAME wilcard suppor & name validation
Date: Tue, 13 Jan 2004 14:27:45 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040113222745.GA12147@bougret.hpl.hp.com>
References: <20040112234332.GA1785@bougret.hpl.hp.com> <20040113142204.0b41403b.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040113142204.0b41403b.shemminger@osdl.org>
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2004 at 02:22:04PM -0800, Stephen Hemminger wrote:
> Here is an enhanced version of the previous patch.
> It adds both the wildcard support that Jean did, and validation of network
> device names.

	Excellent. Your patch looks much cleaner.

> It doesn't check the error return from class_device_rename because
> that will not fail unless object or name are null.

	I was not 100% sure if this would remain true.

	Thanks !

	Jean
