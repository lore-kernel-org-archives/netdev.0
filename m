From: Josh Boyer <jwboyer@redhat.com>
Subject: e1000 vlan functionality broken in 3.1
Date: Mon, 21 Nov 2011 14:28:39 -0500
Message-ID: <20111121192839.GA2585@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fedoraproject.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

We've had a couple of reports of the e1000 driver no longer working with
tagged VLANs in the 3.1 kernel.  The bug report has much more detail
here:

https://bugzilla.redhat.com/show_bug.cgi?id=754589

The summary is, if you turn of rxvlan and tx offloading, the driver
seems to work fine with 3.1 again whereas this wasn't needed on 3.0.
(Fedora calls 3.0 2.6.40 on Fedora 15, but that is strictly a naming
thing.)

Looking through the commit logs, 5622e4044a91 seems to be the most
relevant commit between those versions.  Does anyone have any ideas?

josh
