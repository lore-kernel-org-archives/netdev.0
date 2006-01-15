From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: wireless: recap of current issues (other issues)
Date: Sat, 14 Jan 2006 19:54:45 -0500
Message-ID: <20060115005442.GA32206@tuxdriver.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213237.GH16166@tuxdriver.com> <20060113222408.GM16166@tuxdriver.com> <43C97693.7000109@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751590AbWAOAz1@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <43C97693.7000109@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2006 at 05:09:23PM -0500, Jeff Garzik wrote:
> John W. Linville wrote:
> >Other Issues
> >============
> 
> A big open issue:  should you fake ethernet, or represent 802.11 
> natively throughout the rest of the net stack?
> 
> The former causes various and sundry hacks, and the latter requires that 
> you touch a bunch of non-802.11 code to make it aware of a new frame class.

I had this entry in the "compatibility" section:

We need to be an 802.11 stack (i.e. drivers need to handle 802.11
frames).  Ethernet emulation is bound to paint us into a corner
eventually (if it hasn't already)

My opinion is that we need to 'bite the bullet' and make the kernel
aware of 802.11.  I figure we can leverage some existing work by
davem and acme for this.

John
-- 
John W. Linville
linville@tuxdriver.com
