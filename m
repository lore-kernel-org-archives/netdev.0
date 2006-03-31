From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: [PATCH 2/9] I/OAT
Date: Fri, 31 Mar 2006 11:04:14 -0800
Message-ID: <41b516cb0603311104h617a0a7bnc0daefc024911f17@mail.gmail.com>
References: <1143672844.27644.5.camel@black-lazer.jf.intel.com>
	 <20060330062124.GA8545@2ka.mipt.ru>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751289AbWCaTES@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060330062124.GA8545@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Could you please describe how struct ioat_dma_chan channels are freed?

Sorry, I got distracted by other issues and never ended up following
up on this.  You're right, and it's just sloppiness on my part for
missing it, those structs are being leaked on module unload.  I'll fix
it.  Thanks.

-Chris
