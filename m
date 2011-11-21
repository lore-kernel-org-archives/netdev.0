From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: e1000 vlan functionality broken in 3.1
Date: Mon, 21 Nov 2011 23:05:10 +0100
Message-ID: <20111121220509.GA2444@minipsycho>
References: <20111121192839.GA2585@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fedoraproject.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111121192839.GA2585@zod.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Nov 21, 2011 at 08:28:39PM CET, jwboyer@redhat.com wrote:
>Hi All,
>
>We've had a couple of reports of the e1000 driver no longer working with
>tagged VLANs in the 3.1 kernel.  The bug report has much more detail
>here:
>
>https://bugzilla.redhat.com/show_bug.cgi?id=754589
>
>The summary is, if you turn of rxvlan and tx offloading, the driver
>seems to work fine with 3.1 again whereas this wasn't needed on 3.0.
>(Fedora calls 3.0 2.6.40 on Fedora 15, but that is strictly a naming
>thing.)
>
>Looking through the commit logs, 5622e4044a91 seems to be the most
>relevant commit between those versions.  Does anyone have any ideas?


Looking at the patch again, I do not see anything suspicious. Plus the
bugzilla is talking about carrupting tx packets which is really odd. One
thing I can think of is if maybe VLAN tag inserting/striping and enable
VLAN receive filtering might be needed to be enabled/disabled together.
Intel guys should be able to tell.

Thanks.

Jirka

>
>josh
