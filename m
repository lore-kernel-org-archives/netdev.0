From: John <me@privacy.net>
Subject: Re: Intel 82559 NIC corrupted EEPROM
Date: Wed, 15 Nov 2006 09:34:43 +0100
Message-ID: <455AD123.4080804@privacy.net>
References: <454B7C3A.3000308@privacy.net> <454BF0F1.5050700@zytor.com> <45506C9A.5010009@privacy.net> <4551B7B8.8080601@privacy.net> <4807377b0611080926x21bd6326xc5e7683100d20948@mail.gmail.com> <45533801.7000809@privacy.net> <4807377b0611091619v6bfe17f4tbcbb64db0ab8ea9@mail.gmail.com> <45546A93.6070905@privacy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMT02001.global-sp.net ([193.168.50.54]:29082 "EHLO
	SMT02001.global-sp.net") by vger.kernel.org with ESMTP
	id S966691AbWKOIdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 03:33:54 -0500
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <45546A93.6070905@privacy.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John wrote:

> 00000000-0009ffff : System RAM
> 000a0000-000bffff : Video RAM area
> 000f0000-000fffff : System ROM
> 00100000-0ffeffff : System RAM
>   00100000-00296a1a : Kernel code
>   00296a1b-0031bbe7 : Kernel data
> 0fff0000-0fff2fff : ACPI Non-volatile Storage
> 0fff3000-0fffffff : ACPI Tables
> 20000000-200fffff : 0000:00:08.0
> 20100000-201fffff : 0000:00:09.0
> 20200000-202fffff : 0000:00:0a.0
> e0000000-e3ffffff : 0000:00:00.0
> e5000000-e50fffff : 0000:00:08.0
> e5100000-e51fffff : 0000:00:09.0
> e5200000-e52fffff : 0000:00:0a.0
> e5300000-e5300fff : 0000:00:08.0
> e5301000-e5301fff : 0000:00:0a.0
> e5302000-e5302fff : 0000:00:09.0
> ffff0000-ffffffff : reserved
> 
> I've also attached:
> 
> o config-2.6.18.1-adlink used to compile this kernel
> o dmesg output after the machine boots

I suppose the information I've sent is not enough to locate the
root of the problem. Is there more I can provide?
