From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6 0/14] e1000: driver update
Date: Thu, 06 Jan 2005 21:38:03 -0500
Message-ID: <41DDF60B.5060402@pobox.com>
References: <Pine.LNX.4.44.0501061520290.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0501061520290.7330-100000@isotope.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan wrote:
> 1 ITR does not default correctly on 2.6.x kernels
> 2 Fix kernel panic when the interface is brought down while the NAPI enabled driver is under stress
> 3 Fix ethtool diagnostics -- specifically for blade server implementations
> 4 Enabling NETIF_F_SG without checksum offload is illegal -- jdmason@us.ibm.com
> 5 Avoid filling tx_ring completely - shemminger@osdl.org
> 6 Apply patch from Jamal (hadi@znyx.com) to remove a redundant assignment to a local nr_frags in e1000_xmit_frame.
> 7 Replace schedule_timeout() with msleep()/msleep_interruptible() nacc@us.ibm.com
> 8 Fix tx resource cleanup logic
> 9 {set, get}_wol is now symmetric for 82545EM adapters
> 10 Kernel API change for Module_param_array_named
> 11 Added workaround to prevent inadvertent gigabit waveform to be sent out on the wire due to init-time operations on the IGP phy.
> 12 Applied eeprom fix where it was possible to read/write one more word than what should have been possible.
> 13 Applied smart speed fix where the code was forcing smart speed on all the time.  Now it will honor the setting defined in the eeprom.
> 14 Driver version number, white spaces, comments, device id & other changes

applied patches 1-14 to 2.6.x.

request for the future:  please modify your patch submission procedure 
as follows:

1) create a descriptive subject line of no more than 60 characters

2) include an extended description of the change (> 60 characters) in 
the body of the email.

3) in the email subject line, please include the _specific_ version of 
the kernel your patch is diff'd against.  i.e. "2.6.10-bk1", "2.6.10", 
"2.4.21-pre2", etc.

More details see http://linux.yyz.us/patch-format.html

	Jeff
