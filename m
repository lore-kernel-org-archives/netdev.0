From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFR] new e100 driver
Date: Fri, 05 Dec 2003 13:01:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD0C7EF.40305@pobox.com>
References: <20031205063842.GA23843@gtf.org> <20031205164347.B1291@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031205164347.B1291@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> On Fri, Dec 05, 2003 at 01:38:43AM -0500, Jeff Garzik wrote:
> 
>>e100 3.0.9_dev just got checked into net-drivers-2.5-exp queue.  As I do
>>occasionally (especially for smaller drivers), I post them for review
>>and comment.
> 
> 
> How would I build it? A patch for the Makefile is missing.

Download the net-drivers-2.5-exp patch I am about to post :)


>>Patches welcome in addition to comments.
>>
>>One thing I am tempted to request is use of the new module_param()...
> 
> 
> Does anybody have a macro that turns module_parm() into MODULE_PARM() for
> 2.4 compatibility?

Due to semantics of MODULE_PARM(), that's impossible AFAIK.



>> *	References:
>> *		Intel 8255x 10/100 Mbps Ethernet Controller Family,
>> *		Open Source Software Developers Manual,
>> *		http://sourceforge.net/projects/e1000
> 
> [cut]
> 
>> * 	Hardware padding of short packets to minimum packet size is
>> * 	enabled.  82557 pads with 7Eh, while the later controllers pad
>> * 	with 00h.
> 
> 
> I would be nice if the documentation said so. A few days ago I spent half an
> hour or so trying to figure out why frames sent by an 82558 were padded with
> 0x00 rather than the documented 0x7e (with no sign of skb_padto(), memset()
> or anything similiar in the driver).

Do you mean the PDF documentation?  I dunno how much control Scott 
Feldman and his team have over that.

	Jeff
