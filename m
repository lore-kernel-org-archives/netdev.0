From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: allow per-board firmware overriding
Date: Sat, 18 Apr 2009 21:09:27 -0700 (PDT)
Message-ID: <20090418.210927.229687293.davem@davemloft.net>
References: <20090417095038.49b745bf@dhcp-lab-109.englab.brq.redhat.com>
	<49EA1DAC.1000602@myri.com>
	<1240102617.5342.6.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com, sgruszka@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752961AbZDSEJs@vger.kernel.org>
In-Reply-To: <1240102617.5342.6.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Dillow <dave@thedillows.org>
Date: Sat, 18 Apr 2009 20:56:57 -0400

> It seems like this could be done in user space, using the PCI bus ID as
> a key to select the firmware.

PCI BUS ID's are not in any way unique, you would need to include the
PCI Domain as well.
