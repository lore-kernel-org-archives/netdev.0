From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: dhcp-based netboot over jumbo-frame network?
Date: Wed, 08 Apr 2009 16:10:34 -0600
Message-ID: <49DD20DA.3020902@nortel.com>
References: <49DCE470.9060109@nortel.com> <49DCF7E2.2060304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754773AbZDHWKx@vger.kernel.org>
In-Reply-To: <49DCF7E2.2060304@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Chris Friesen wrote:

>> We have an existing system that loads a bare kernel using tftp, then 
>> mounts a rootfs via NFS.  The wrinkle is that this is on a jumbo-frame 
>> enabled network, so somehow the MTU needs to be set before mounting the 
>> rootfs.
> 
> Why?  Is the NFS mount not TCP?  If it is TCP, then the TCP MSS exchange will 
> provide you cover as it will (should) cause TCP in the NFS server to segment to 
> the MSS option your system with the then-smaller MTU sends.
> 
> I would think that only if the NFS mount is UDP that you would have a problem 
> with the system initially booting with a small MTU.

Currently it uses the default, which is udp.  I might be able to get 
them to try TCP.  Thanks for the suggestion.

>> In a previous version we patched ipconfig.c to support the DHCP option 
>> to specify the MTU value, but I'm wondering about the "proper" way to do 
>> this on current kernels.
> 
> Was the change submitted to upstream and rejected?

The change was submitted (not by us) back in the 2.6.10 timeframe, and 
was rejected with the suggestion to use initramfs.

Chris
