From: Douglas Gilbert <dougg@torque.net>
Subject: Re: Bad escriptions in Kconfig
Date: Mon, 31 Dec 2007 11:34:58 -0500
Message-ID: <47791A32.1020405@torque.net>
References: <alpine.LSU.0.999.0712311313050.3761@be1.lrz> <477907DB.8030406@torque.net> <20071231154731.GY11638@parisc-linux.org>
Reply-To: dougg@torque.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bodo Eggert <7eggert@gmx.de>, linux-kernel@vger.kernel.org,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20071231154731.GY11638@parisc-linux.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Mon, Dec 31, 2007 at 10:16:43AM -0500, Douglas Gilbert wrote:
>> Bodo Eggert wrote:
>>> ---
>>> SCSI target support (SCSI_TGT) [N/m/y/?] (NEW) ?
>>>
>>> If you want to use SCSI target mode drivers enable this option.
>>> If you choose M, the module will be called scsi_tgt.
>>> ---
>>>
>>> What TF is a SCSI target mode, what is a target mode driver?
>> Heard of google :-)
>>
>> For explanations of SCSI (and other storage) terminology
>> reference could be made to SAM-3 or SAM-4 drafts (because
>> the real standards cost money) at www.t10.org .
>>
>> Perhaps many other subsections in the kernel could have
>> similar references.
> 
> I think that's an appalling idea.  Someone's trying to configure their
> kernel, not research hundreds of new ideas on the internet.  Here's a
> better description:
> 
> 	help
> 	  The SCSI target code allows your computer to appear as a SCSI
> 	  device.  This is useful in a SAN or NAS environment where you
> 	  want other computers to be able to treat this computer as a disc.
> 
> 	  To compile this driver as a module, choose M here: the module
> 	  will be called scsi_tgt.

Appalling or not, it is more accurate to define a SCSI target
properly than equate it to a direct access logical unit (i.e.
a disk). IMO the designers of that driver and associated
applications made exactly the same mistake which they are now
fixing. That driver is also transport specific with support
for iSCSI and iSER. Try writing a SPI, FC or SAS target driver
for scsi_tgt (I failed with SAS).

It could also be noted that if the reader doesn't understand
the description they can most likely say 'N'.

Doug Gilbert

