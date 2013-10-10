From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH] usbnet: smsc95xx: Add device tree input for MAC address
Date: Thu, 10 Oct 2013 20:39:06 +0800
Message-ID: <CACVXFVP-KgqcNTnk+JZsLc188pYk6iUXvW6=kPXNaurSuevGeA@mail.gmail.com>
References: <1380911156-14112-1-git-send-email-dmurphy@ti.com>
	<CACVXFVOVMvP=3y9h2Jrqn2sBQdKOZtrhQDAFYkdHKXFgQj=d0Q@mail.gmail.com>
	<52519E7A.40804@ti.com>
	<CACVXFVNAB3VnmdoP_LGJsBjQ17j1aoqKMsBE7LRt65OqROeRUQ@mail.gmail.com>
	<525698CC.3060406@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>, mugunthanvnm@ti.com
To: Dan Murphy <dmurphy@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525698CC.3060406@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2013 at 8:08 PM, Dan Murphy <dmurphy@ti.com> wrote:
>
> You are correct I don't expect a match for PnP devices only devices that are hard wired.
>
> After thinking of it I should move the OF code below the EEPROM code as the EEPROM should take preference over the DT code.
>
> I will need to post V2 for that.

Your patch still doesn't deal with two smsc95xx devices built in
one board.

The problem is a generic one, looks it is better to do it when OF supports
discoverable bus.


Thanks,
-- 
Ming Lei
