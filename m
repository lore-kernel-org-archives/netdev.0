From: Hanjun Guo <hanjun.guo@linaro.org>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Wed, 23 Sep 2015 16:56:00 -0700
Message-ID: <56033C10.2040708@linaro.org>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com> <1439417187-21411-3-git-send-email-jeremy.linton@arm.com> <1443033714.74600.18.camel@infradead.org> <560310EA.2070805@intel.com> <1443042212.74600.30.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	Catalin.Marinas@arm.com, Suravee.Suthikulpanit@amd.com,
	grant.likely@linaro.org
To: David Woodhouse <dwmw2@infradead.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33783 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756129AbbIWX4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:56:11 -0400
Received: by pacex6 with SMTP id ex6so54205280pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 16:56:10 -0700 (PDT)
In-Reply-To: <1443042212.74600.30.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2015 02:03 PM, David Woodhouse wrote:
> On Wed, 2015-09-23 at 22:51 +0200, Rafael J. Wysocki wrote:
>>
>> But if the device ID is assigned already, why would it hurt to
>> actually use it?
>
> It doesn't hurt at all, as long as we understand that there was no need
> to assign it a device ID at all, at least for Linux's benefit. And as
> long as it doesn't set a precedent that makes other people think they
> need to do so.

It really depends on the people who writing the ASL code (DSDT),
I'm not sure if Windows will use _DSD and how to use it, but
firmware guys may just use the device ID to make the firmware
to be usable both by Linux and Windows, and that's reasonable
I think.

Thanks
Hanjun
