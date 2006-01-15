From: "David S. Miller" <davem@davemloft.net>
Subject: Re: wireless: recap of current issues (other issues)
Date: Sat, 14 Jan 2006 17:51:40 -0800 (PST)
Message-ID: <20060114.175140.07007614.davem@davemloft.net>
References: <20060113213237.GH16166@tuxdriver.com>
	<20060113222408.GM16166@tuxdriver.com>
	<43C97693.7000109@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751600AbWAOB4H@vger.kernel.org>
To: jgarzik@pobox.com
In-Reply-To: <43C97693.7000109@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Sat, 14 Jan 2006 17:09:23 -0500

> A big open issue:  should you fake ethernet, or represent 802.11 
> natively throughout the rest of the net stack?
> 
> The former causes various and sundry hacks, and the latter requires that 
> you touch a bunch of non-802.11 code to make it aware of a new frame class.

The former, most importantly, can cause the packet to get copied.
Actually, this depends upon how you implement things and when the
header change occurs.

My vote is for making the whole of the networking 802.11 frame class
aware.
