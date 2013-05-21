From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v3] Bluetooth: hidp: using strlcpy instead of strncpy,
 also beautify code.
Date: Tue, 21 May 2013 09:40:02 +0800
Message-ID: <519AD072.1090102@asianux.com>
References: <518906A8.7060708@asianux.com> <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com> <5189A417.503@asianux.com> <5189C7C6.8090408@asianux.com> <alpine.LNX.2.00.1305091041140.23038@pobox.suse.cz> <51904ACF.6010904@asianux.com> <20130520215224.GE17712@joana>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Gustavo Padovan <gustavo@padovan.org>,
	Jiri Kosina <jkosina@suse.cz>,
	David Herrmann <dh.herrmann@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	David Miller <davem@davemloft.net>,
	andrei.emeltchenko@intel.com,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:39801 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663Ab3EUBk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 21:40:56 -0400
In-Reply-To: <20130520215224.GE17712@joana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/21/2013 05:52 AM, Gustavo Padovan wrote:
> Hi Chen,
> 
> * Chen Gang <gang.chen@asianux.com> [2013-05-13 10:07:11 +0800]:
> 
>> > 
>> > For NUL terminated string, need always let it ended by zero.
>> > 
>> > Since have already called memcpy() to initialize 'ci', so need not
>> > redundant initialization.
>> > 
>> > Better use ''if(session->hid) {} else if(session->input) {}"" instead
>> > of ''if(session->hid) {}; if(session->input) {};''
>> > 
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> > ---
>> >  net/bluetooth/hidp/core.c |   14 ++++----------
>> >  1 files changed, 4 insertions(+), 10 deletions(-)
> Sorry for the big delay on this, patches has now been applied to
> bluetooth-next. Thanks all.

It doesn't matter, every member have their own work, especially, most of
us are busy.

Thank you for your work, too.


Thanks.
-- 
Chen Gang

Asianux Corporation
