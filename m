From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: Re: Re: Re: Re: A reliable kernel panic (3.6.2) and system crash
 when visiting a particular website
Date: Sun, 21 Oct 2012 11:23:30 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210211121370.14867-100000@netrider.rowland.org>
References: <121566322.100103.1350820776893.JavaMail.mail@webmail20>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bp@alien8.de, <pavel@ucw.cz>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <security@kernel.org>,
	<linux-media@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <121566322.100103.1350820776893.JavaMail.mail@webmail20>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 21 Oct 2012, Artem S. Tashkinov wrote:

> What I've found out is that my system crashes *only* when I try to enable
> usb-audio (from the same webcam) - I still have no idea how to capture a
> panic message, but I ran
> 
> "while :; do dmesg -c; done" in xterm, then I got like thousands of messages
> and I photographed my monitor:
> 
> http://imageshack.us/a/img685/9452/panicz.jpg
> 
> list_del corruption. prev->next should be ... but was ...
> 
> I cannot show you more as I have no serial console to use :( and the kernel
> doesn't have enough time to push error messages to rsyslog and fsync
> /var/log/messages

Is it possible to use netconsole?  The screenshot above appears to be 
the end of a long series of error messages, which isn't too useful.  
The most important information is in the first error.

Alan Stern
