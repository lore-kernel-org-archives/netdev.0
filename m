From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: lmc: Switch to using managed resources
Date: Wed, 02 Mar 2016 13:44:21 -0500 (EST)
Message-ID: <20160302.134421.1239396775813870620.davem@davemloft.net>
References: <20160227170416.GA1339@amitoj-Inspiron-3542>
	<20160301.172153.99852560992201587.davem@davemloft.net>
	<CA+5yK5F0q=iKD_WAdXD6UWGLOYMt29Vq20Wh0w-Zf4sVFrTK0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+5yK5F0q=iKD_WAdXD6UWGLOYMt29Vq20Wh0w-Zf4sVFrTK0g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Wed, 2 Mar 2016 19:52:42 +0530

> Specifically, pcim_release contains the following code:

How incredibly unintuitive that PCI helper functions magically become
managed just because a driver invoked pcim_enable_device().

Well, if that's what is it, that's what it is.

Applied, thanks.
