From: jamal <hadi@cyberus.ca>
Subject: Re: [SET 2][PATCH 2/8][bonding] Propagating master's settings to
	slaves
Date: 11 Aug 2003 22:36:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060655768.1029.57.camel@jzny.localdomain>
References: <200308112141.h7BLftpS015012@death.ibm.com>
	 <200308120215.18234.shmulik.hen@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>,
   Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308120215.18234.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Shmulik, the only discussion as far as i know is the one that happened
in this thread. I have not seen any discussion before. 

Folks, I really didnt mean to start such a long thread ;->

cheers,
jamal

On Mon, 2003-08-11 at 19:15, Shmulik Hen wrote:
> May I remind you all that the original discussion was only about  
> stuff that has to do with configuration time. There was no mention of 
> any run time code. ifenslave only does three simple things - add a 
> slave, remove a slave and set the current active slave, that's all. 
> 
> The drive was to try and make ifenslave slimmer regarding those three 
> operations only in the way that any setting of the slave will be done 
> by the kernel module instead of the configuration application. There 
> is no real "brain" there anyway.
> 
> We had some experience with creating an configuration application that 
> was incredibly smart and was always aware of what was going on in the 
> driver and could make all possible decisions before even attempting 
> to access the driver so it could fail the operation without  
> "bothering" the driver. It's gigantic. It's extremely hard to install 
> and configure. It's even harder to maintain. And all it was meant to 
> do is configuration. Imagine what would happen if it was also 
> supposed to handle run time issues.
> 
> I am not aware of anything like moving kernel code into applications. 
> Was that something that was discussed in OLS ? Where can I find some 
> more info about this trend ?
> 
> 
> 	Shmulik.
> 
> 
