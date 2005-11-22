From: "Jeff V. Merkey" <jmerkey@soleranetworks.com>
Subject: Re: e1000 82571 Packet Splitting
Date: Tue, 22 Nov 2005 15:27:57 -0700
Message-ID: <43839B6D.9060301@soleranetworks.com>
References: <43838614.9080807@soleranetworks.com> <4807377b0511221546h7a16c0a9p793e441197b23118@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030258AbVKVXww@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0511221546h7a16c0a9p793e441197b23118@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:

>this should be on netdev.
>
>On 11/22/05, Jeff V. Merkey <jmerkey@soleranetworks.com> wrote:
>  
>
>>I have noted that the e1000 driver is now supporting DMA splitting of
>>the packet header and payload into separate pages.  I also noticed
>>that none of the config options enable it.  Is anyone using this feature
>>at present and has it even been tested on Linux?
>>    
>>
>
>The 6.2.15 driver off http://prdownloads.sf.net/e1000 will enable it
>by default.  We've gone through our release approval, which includes
>quite a bit of testing.
>If the patches posted recently don't include that support, I missed
>something :-)
>
>This is only on the 82571 and greater hardware that packet split is
>supported, BTW.
>
>  
>
Got it.  I am merging packet capture support into the e1000 for DSFS for 
direct cache DMA support.  I noticed the two distinct fill routines
for the ring buffer.  I have enabled DSFS for both with this driver.  I 
will post patches late tonight or in the morning for the 82571 support 
for DSFS.  I will
also be posting the patches for 2.6.12, 2.6.10. 2.6.14, Suse 9 and 10.0, 
Red Hat ES/AS 3 and 4, and Fedora Core 2/3/4 by end of week with the
packet splitting capabilities with packet capture on DSFS.  This is a 
very good optimization and should come in handy for reducing header copies
in the protocol stacks.

Jeff
