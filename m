From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 10:12:51 -0700
Message-ID: <CAKgT0UdTgaeamyLetGPK0mqMNS-80BTc8t-WdSGJuuLDfz4JOg@mail.gmail.com>
References: <20160330064213.12927.46852.stgit@localhost.localdomain>
	<20160330170011.GB27540@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34920 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbcC3RMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 13:12:52 -0400
Received: by mail-io0-f180.google.com with SMTP id g185so82639265ioa.2
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 10:12:52 -0700 (PDT)
In-Reply-To: <20160330170011.GB27540@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 10:00 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/29/16 23:44), Alexander Duyck wrote:
>> This patch has been sanity checked only.  I cannot yet guarantee it
>> resolves the original issue that was reported.  I'll try to get a
>> reproduction environment setup tomorrow but I don't know how long that
>> should take.
>
> I tried this out with rds-stress on my test-pair, unfortunately, I
> still see the Tx hang.
>
> Setting up the test is quite easy- for reference, the instructions
> are here:
>    https://sourceforge.net/p/e1000/mailman/message/34936766/

Yeah.  The patch was sort of a knee-jerk reaction to being told that
the patch referenced caused a regression.  From what I can tell that
is not the case as I am also seeing the Tx hangs when I run the test
with the frames being linearized.

I'll do some research this morning to see if I can find a root cause.
Unfortunately the malicious driver detection isn't very well
documented so I can't be certain what is causing it to be triggered.

- Alex
