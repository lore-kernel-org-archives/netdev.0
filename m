From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: e1000 82571 Packet Splitting
Date: Tue, 22 Nov 2005 15:46:52 -0800
Message-ID: <4807377b0511221546h7a16c0a9p793e441197b23118@mail.gmail.com>
References: <43838614.9080807@soleranetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030261AbVKVXqy@vger.kernel.org>
To: "Jeff V. Merkey" <jmerkey@soleranetworks.com>
In-Reply-To: <43838614.9080807@soleranetworks.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this should be on netdev.

On 11/22/05, Jeff V. Merkey <jmerkey@soleranetworks.com> wrote:
>
> I have noted that the e1000 driver is now supporting DMA splitting of
> the packet header and payload into separate pages.  I also noticed
> that none of the config options enable it.  Is anyone using this feature
> at present and has it even been tested on Linux?

The 6.2.15 driver off http://prdownloads.sf.net/e1000 will enable it
by default.  We've gone through our release approval, which includes
quite a bit of testing.
If the patches posted recently don't include that support, I missed
something :-)

This is only on the 82571 and greater hardware that packet split is
supported, BTW.
