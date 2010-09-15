From: Thomas Backlund <tmb@mandriva.org>
Subject: Re: [33-stable regression ssb/broadcom]
Date: Wed, 15 Sep 2010 12:54:02 +0300
Message-ID: <4C9097BA.1080208@mandriva.org>
References: <4C8E6192.2010003@mandriva.org> <20100913.122329.39186333.davem@davemloft.net> <20100913193647.GD4052@tuxdriver.com> <4C8E8AC2.2030201@mandriva.org> <4C8E8C73.60306@mandriva.org> <20100913210145.GA18969@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "stable@kernel.org" <stable@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	"Larry.Finger@lwfinger.net" <Larry.Finger@lwfinger.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox1.netikka.net ([213.250.81.202]:53592 "EHLO
	mbox1.netikka.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab0IOJyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 05:54:07 -0400
In-Reply-To: <20100913210145.GA18969@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH skrev 14.9.2010 00:01:
> On Mon, Sep 13, 2010 at 11:41:23PM +0300, Thomas Backlund wrote:
>> Thomas Backlund skrev 13.9.2010 23:34:
>>> John W. Linville skrev 13.9.2010 22:36:
>>>> On Mon, Sep 13, 2010 at 12:23:29PM -0700, David Miller wrote:
>>>>> From: Thomas Backlund<tmb@mandriva.org>
>>>>> Date: Mon, 13 Sep 2010 20:38:26 +0300
>>>>>
>>>>>> In Mandriva 2010.1 we noticed that 2.6.33.7 broke ssb/Broadcom lan for
>>>>>> several users...
>>>>>>
>>>>>> Issue is tracked at:
>>>>>> https://qa.mandriva.com/show_bug.cgi?id=60968
>>>>>>
>>>>>> Reverting the commit restores a working lan.
>>>>>>
>>>>>> The offending commit is:
>>>>>
>>>>> Please always CC: netdev on networking reports, otherwise you are
>>>>> very unlikely to get any experts looking into your issue.
>>>>
>>>> IIRC, there was a bad patch that got sent for the 2.6.33.y series.
>>>> I thought it had been reverted or fixed already?
>>>>
>>>
>>> Nope.
>>>
>>> It got added in 2.6.33.7
>>> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.33.y.git;a=commit;h=6fb037c2ed8378c7ab0c1e00536ba6b2a866503e
>>>
>>
>> After checking some more...
>>
>> I see the revert of the broken patch was done in 2.6.34.3 and a set
>> of ssb patches replacing it...
>>
>> but it didn't happend for 2.6.33.y
>
> Yeah, I think I "dropped" support for .33 by then and I really didn't
> care anymore.
>

Yep.
final 2.6.33.7 was released 8 days before 2.6.34.3.

> Note, I have gotten a few rumblings that I should bring .33 back to life
> for some loving due to a few distros relying on it, but I need to find
> the time in my schedule to do so...
>

Well,
if you dont want to really bring it back to life, I'd suggest to simply
released a 2.6.33.8 with only reverting the broken patch as it would 
"unbreak" the tree and call it a day :-)

Otherwise...
I now have merged the ssb fixes from 26.34.3:
19bfed793ee38ce027326a3c518ff6201f673a8d ssb: do not read SPROM if it 
does not exist
3ca696ca403b2715018bd5c693ab105c3a3ea888 ssb: Look for SPROM at 
different offset on higher rev CC
a8515c84db1a9c9be19d8d873b059473474b6dab ssb: fix NULL ptr deref when 
pcihost_wrapper is used
8235ddc2cd7a3367b688e0ed52ab377eac6cfad4 ssb: Handle alternate SSPROM 
location

into 2.6.33.7 after reverting the broken commit and have confirmation 
from users that it still works, so thats what I'll do for Mandriva 2010.1

--
Thomas
