From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Device naming for wireless NICs...
Date: Thu, 11 Mar 2004 10:22:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040311182204.GA5989@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, James Ketrenos <jketreno@linux.co.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote :
> 
> If this topic been hashed a lot already, please let me know the
> keywords I might search for in the archives to find the threads.
> 
> I've had a few requests by users of the IPW2100 wireless driver to
> switch the default interface name to be wlanX vs. ethX.  In my prior
> searches through the wireless drivers in the 2.6.3 kernel tree, I
> couldn't find any that changed from the default.

	This is my personal rule of thumb :
	o if the interface use Ethernet frames (i.e. offer Ethernet
emulation), then it should be name 'ethX'.
	o if the interface use 802.11 frames (rawe/native), it should
use 'wifiX'.

	The Aironet driver is a good example of this, for each
hardware it offers two interfaces, 'ethX' and 'wifiY'.
	Personally, I've been converting a few drivers to use 'ethX'
and removing 'wlanX' hacks where I saw them..

> I don't mind adding a module parameter to change the default name
> (if that is the standard practice), but thought I'd see what others
> thing rather than just going off and doing something random.

	Just point them to :
http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/HOTPLUG.txt

> Is there a technical or ease of use reason switching away from ethX?
> My thinking in keeping it eth was that it then represents a greater
> chance of "just working" with most networking scripts and utilities
> that may assume ethX is the interface name.

	Note that the RedHat graphical configuration tool (neat) seems
to insist on only using 'ethX' names. Yes, only using 'ethX' is
generally safer (principle of least surprise).

	Have fun...

	Jean
