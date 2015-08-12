From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/6] geneve: Make dst-port configurable.
Date: Wed, 12 Aug 2015 11:13:31 -0700
Message-ID: <CAEP_g=8dP-_jmcxL5o3=DC6H7pkhB8MOcrRuEsb37OxqoWzVDA@mail.gmail.com>
References: <1439356660-21754-1-git-send-email-pshelar@nicira.com>
 <CAEP_g=9biFJDxbAFMBB+mbttBnbEkykJx7z24HrhUdjA25YpNg@mail.gmail.com> <CALnjE+rAsxUjGa3FADsnW8ZJtBYMPHEcbWEDT4WpcM05ki7M=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33414 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbbHLSNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 14:13:52 -0400
Received: by lalv9 with SMTP id v9so13689283lal.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 11:13:50 -0700 (PDT)
In-Reply-To: <CALnjE+rAsxUjGa3FADsnW8ZJtBYMPHEcbWEDT4WpcM05ki7M=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 10:57 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Aug 12, 2015 at 10:00 AM, Jesse Gross <jesse@nicira.com> wrote:
>> Not specific to this patch but I think that it will make things
>> significantly easier in the future if changelink was implemented.
>> VXLAN has the same issue as well.
>
> Do you mean allow dst-port configuration only through changelink()?

This would be in addition to the ability to change it at setup, as
done by this patch.

I think we should ideally allow all netlink configuration to be
changed at runtime. Otherwise the only other choice is to delete and
recreate the device, which is more disruptive.
