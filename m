From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: Setting alternate MAC addresses on e1000
Date: Wed, 02 Apr 2008 10:07:18 +0200
Message-ID: <47F33EB6.1050402@aei.mpg.de>
References: <47F2358A.8080505@aei.mpg.de> <36D9DB17C6DE9E40B059440DB8D95F5204D09A67@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:36817 "EHLO welcomes-you.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785AbYDBIHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 04:07:23 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204D09A67@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

thanks for the hint, I was stupid to think these two NIC are just using 
the very same EEPROM.

Brandeburg, Jesse wrote:
> Carsten Aulbert wrote:
>> where magic is MAGIC=0x108c8086
>>
>> However this does not work on eth1 :(
> 
> I think you need a different MAGIC for eth1 since they are separate
> parts (different device ID) with separate eeproms, then the first 6 byte
> change should work for eth1 too.
> 

Yes, with MAGIC=0x109a8086 I can set the MAC address of eth1.

> in the future e1000-devel@lists.sf.net might be more appropriate to
> Intel specific hardware questions.  but copying netdev is still okay.

Will do, starting with a closely related question:

The Intel specs state that word 37H is a pointer to an "alternate MAC 
address". My boss things it would be wise to let the original MAC 
address in place and just add another MAC address, so that we can easily 
revert to the old "official" one by writing 0xffff into that word.

Has anyone experience with that approach? In principle that should be 
easy, however, I don't know where/how to find 6 free bytes from the 
table given in Intel's docs.

Thanks again and hopefully someone has some light for my brain ;)

Cheers

Carsten
