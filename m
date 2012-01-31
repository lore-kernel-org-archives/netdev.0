From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] smsc95xx: add macaddr module parameter
Date: Tue, 31 Jan 2012 17:27:31 +0000
Message-ID: <20120131172731.03df5704@pyramind.ukuu.org.uk>
References: <1328030433-12524-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Danny Kukawka <dkukawka@suse.de>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328030433-12524-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jan 2012 18:20:33 +0100
Danny Kukawka <danny.kukawka@bisect.de> wrote:

> Added smsc95xx.macaddr module parameter to allow the user to
> change the MAC address on boot if there was no MAC on the EEPROM.

NAK. Please see the discussion on this and ifconfig hw for other devices.

In summary - make the device refuse to ifconfig up without a valid
address, allow it to come into existance without a valid address and then
use ifconfig.


Your patch also seems to break if there are several attached to a board.
