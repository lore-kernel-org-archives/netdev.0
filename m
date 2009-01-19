From: Patrick McHardy <kaber@trash.net>
Subject: Re: e1000 fails to initialize in current -git
Date: Mon, 19 Jan 2009 22:08:25 +0100
Message-ID: <4974EBC9.40907@trash.net>
References: <496AE0A5.903@trash.net> <F169D4F5E1F1974DBFAFABF47F60C10A1A07DD00@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47799 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107AbZASVI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:08:27 -0500
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1A07DD00@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> Patrick McHardy wrote:
>> [    1.495882] e1000: EEPROM initialization failed
>> [    1.516170] e1000 0000:00:0c.0: PCI INT A disabled
>> [    1.516252] e1000: probe of 0000:00:0c.0 failed with error -5
>>
>> and the device is not registered. If someone wants me to test patches
>> or do something else, just let me know.
> 
> are you still having this issue?  My guess is that it may be because
> the pci_enable_device logic for devices in D3 got broken, but I think 
> that is now fixed.

It seems to be fixed, I tried -rc2 and the device is working again.
