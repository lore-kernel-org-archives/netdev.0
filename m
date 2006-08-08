From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: 2.6.18-rc3-mm2: bad e1000 device name
Date: Tue, 08 Aug 2006 08:25:50 -0700
Message-ID: <44D8ACFE.3060802@goop.org>
References: <44D78A48.7050707@goop.org> <20060808004011.ab3cd65f.akpm@osdl.org> <44D8484E.9050904@goop.org> <44D8AB08.3000006@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964952AbWHHPZm@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <44D8AB08.3000006@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Jeremy Fitzhardinge wrote:
>> Andrew Morton wrote:
>>> e1000 seems OK here.  Don't know, sorry.
>>>   
>>
>> It's happening to all my ethernet-like devices: the Atheros wireless 
>> comes up as a mess too.  It's different each time, so it looks like 
>> random uninitialized crud.
>>
>
> is this the binary atheros driver? then please try without that.. 

It happens regardless of whether the atheros driver is loaded (or has 
ever been loaded).  But it also happens to the atheros driver, so it 
isn't specific to the e1000.

    J
