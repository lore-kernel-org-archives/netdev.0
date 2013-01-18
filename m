From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Fri, 18 Jan 2013 15:29:23 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1301181524110.1190-100000@iolanthe.rowland.org>
References: <20130118.142316.708739494707619536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: freddy@asix.com.tw, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<louis@asix.com.tw>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130118.142316.708739494707619536.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Jan 2013, David Miller wrote:

> > +	ret = fn(dev, cmd, USB_DIR_IN | USB_TYPE_VENDOR |
> > +			USB_RECIP_DEVICE, value, index, data, size);
> 
> This is not indented properly.  When a function call takes up
> multiple lines, the text on the second and subsequent lines must
> be left justified to the first column after the openning parenthesis
> of the function call, like this:
> 
> 	function(arg1, arg2,
> 		 arg3, arg4);
> 
> You must use the appropriate combination of TAB and space characters
> to achieve this.  If you are trying to only use TAB characters, you
> are doing it wrong.

Documentation/CodingStyle doesn't mention this.  Does the networking 
stack have its own special requirements, not listed in CodingStyle?

Alan Stern

P.S: The standard I have tried to follow for USB code is to indent
continuation lines by two tab stops more than the first line,
regardless of whether the break occurs inside a function call.  I have
seen other people consistently indent continuation lines by 1/2 tab
stop (i.e., four spaces) beyond the first line.
