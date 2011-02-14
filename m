From: Hank Janssen <hjanssen@microsoft.com>
Subject: RE: Process for subsystem maintainers to get Hyper-V code out of
 staging. - CORRECTED RECIPIENTS
Date: Mon, 14 Feb 2011 23:42:20 +0000
Message-ID: <8AFC7968D54FB448A30D8F38F259C56233F957D3@TK5EX14MBXC114.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	Hashir Abdi <habdi@microsoft.com>,
	"Mike Sterling" <Mike.Sterling@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"gregkh@suse.de" <gregkh@suse.de>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-ide@vger.ke
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


MY APOLOGIES-I made a typo on James email address. I corrected it and resend.
Sorry for the double email.

 
Stephen/James/David,

Greetings to you all. As you might be aware, we submitted Hyper-V drivers to the kernel 2009. 
We have been extending these drivers with additional functionality and our primary focus now
is doing the work needed to exit the staging area.

To give you some background, the following are Hyper-V specific Linux drivers:

                hv_vmbus           The vmbus driver that is the bridge between guest and the 
			host
                hv_storvsc          The SCSI device driver
                hv_blkvsc            The IDE driver
                hv_netvsc           The network driver

We think our drivers are pretty close to be reviewed by the subsystem maintainers.

We have been  working with Greg on  hv_vmbus, and several other driver issues as it relates to 
exiting staging. And now we are looking for guidance for the other drivers.

	1. Most important thing of course, did we contact the correct subsystem 
	    maintainers?
		i. IDE/Blkvsc		David Miller
		ii. SCSI/Storvsc		James Bottomley
		iii. Network/Netvsc	Stephen Hemminger
	2. What is the process to submit the code for review?
	3. Which mailing list(s) do we need to use for the code reviews
	4. I assume normal patch format is required?
	5. What additional information is needed
	6. Once they leave staging where do they need to go? Because they all
	    pretty much come as a package we were thinking drivers/hyperv might
	    be a good place.
                
There are still a few outstanding items we are currently working on. But they should be 
wrapped up shortly. (There are a few remaining FIXME comments in the code we are 
cleaning up as I write this). But if possible we would like to get your feedback even 
as we are addressing the issues we currently know about.

Thanks

Hank.




