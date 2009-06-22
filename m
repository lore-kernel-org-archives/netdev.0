From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH] Documentation: add documentation summary for rc-series
	and merge window
Date: Mon, 22 Jun 2009 14:11:45 -0700
Message-ID: <43e72e890906221411od16be51k2fc811dbf223ed9f@mail.gmail.com>
References: <20090622180438.GG23972@bombadil.infradead.org>
	<20090622204500.GB24236@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, Greg KH <greg@kroah.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:5518 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbZFVVMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 17:12:03 -0400
In-Reply-To: <20090622204500.GB24236@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 1:45 PM, Pavel Machek<pavel@ucw.cz> wrote:
> On Mon 2009-06-22 14:04:38, Luis R. Rodriguez wrote:
>> This is losely based on previous discussions on linux-kernel [1][2][3].
>> Lets also refer people reading the stable rules to
>> Documentation/development-process/.
>>
>> Also add the number of days it has taken between releases,
>> and provide the average for the last 10 releases: 86.0 days.
>>
>> [1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
>> [2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2
>> [3] http://marc.info/?l=linux-kernel&m=124515657407679&w=2
>>
>> Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
> NAK.
>
>> +2.0.2: RC-SERIES RULES
>> +
>> +This section summarizes what kind of patches are accepted before the merge
>> +window closes and after it closes. These patches are targeted for the kernel
>> +prior to its final release.
>> +
>> +The rc-series focus should really be to address regressions.
>> +
>> +2.0.2.0: RC-SERIES RULES PRIOR TO THE RC1 RELEASE
>> +
>> +These are the types of patches that will get accepted prior to a kernel rc1 release,
>> +during the merge window:
>> +
>> + - it must fix a regression
>> + - it must fix a security hole
>> + - it must fix a oops/kernel hang
>> +
>> +Non-intrusive bug fixes or small fixes will not be accepted. If the
>> patch in
>
> What? Prior to rc1, new features are accepted.

For maintainers yes, for developers sending to the subsystem
maintainer no, at least not for that kernel release being worked on. I
can try to make this a little clearer.

  Luis
