From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: was: Re: A reliable kernel panic (3.6.2) and system crash when
 visiting a particular website
Date: Sun, 21 Oct 2012 11:28:29 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210211126570.14867-100000@netrider.rowland.org>
References: <5084132B.8080609@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, <bp@alien8.de>,
	<pavel@ucw.cz>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <security@kernel.org>,
	<linux-media@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<alsa-devel@alsa-project.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5084132B.8080609@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 21 Oct 2012, Daniel Mack wrote:

> As the usb list is still in Cc: - Artem's lcpci dump shows that his
> machine features XHCI controllers. Can anyone think of a relation to
> this problem?
> 
> And Artem, is there any way you boot your system on an older machine
> that only has EHCI ports? Thinking about it, I wonder whether the freeze
> in VBox and the crashes on native hardware have the same root cause. In
> that case, would it be possible to share that VBox image?

Don't grasp at straws.  All of the kernel logs Artem has posted show 
ehci-hcd; none of them show xhci-hcd.  Therefore the xHCI controller is 
highly unlikely to be involved.

Alan Stern
