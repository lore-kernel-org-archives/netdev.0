From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Thu, 08 Dec 2005 14:23:40 -0800
Message-ID: <ada4q5jz0r7.fsf@cisco.com>
References: <Pine.LNX.4.44.0512081606060.24134-100000@gate.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Grover <andrew.grover@intel.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<john.ronciak@intel.com>, <christopher.leech@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932358AbVLHWYw@vger.kernel.org>
To: Kumar Gala <galak@gate.crashing.org>
In-Reply-To: <Pine.LNX.4.44.0512081606060.24134-100000@gate.crashing.org> (Kumar
 Gala's message of "Thu, 8 Dec 2005 16:13:52 -0600 (CST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Kumar> I'm actually searching for any examples of drivers that
    Kumar> deal with the issues related to DMA'ng directly two and
    Kumar> from user space memory.

It's not quite the same story as what you're doing with DMA engines
inside the CPU, but you could look at drivers/infiniband, particularly
drivers/infiniband/core/uverbs_mem.c.  That handles pinning and
getting DMA addresses for user memory that will be used as a DMA
target in the future.

 - R.
