From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: pull request: wireless-2.6 2010-05-25
Date: Tue, 25 May 2010 23:18:50 +0200
Message-ID: <4BFC3EBA.1090607@gmail.com>
References: <20100525170401.GE31753@tuxdriver.com> <4BFC331A.9030606@gmail.com> <20100525204235.GA27002@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100525204235.GA27002@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/25/10 22:42, John W. Linville wrote:
> On Tue, May 25, 2010 at 10:29:14PM +0200, Gertjan van Wingerde wrote:
>> On 05/25/10 19:04, John W. Linville wrote:
> 
>>> Gertjan van Wingerde (2):
>>>       rt2x00: Fix rt2800usb TX descriptor writing.
>>
>> The patch causing the breakage this patch fixes wasn't actually upstream yet. So, 
>> applying this patch only is now introducing a bug in 2.6.35. I guess it is better
>> to revert this patch for 2.6.35.
> 
> Hmmm...OK.  Which patch introduces the bug this was intended to fix?
> 

It's this one: 

http://marc.info/?l=linux-wireless&m=127374343617025&w=2

But that patch depends on a number of other unapplied patches :-(, namely:

http://marc.info/?l=linux-wireless&m=127374940425538&w=2
http://marc.info/?l=linux-wireless&m=127374344617058&w=2
and
http://marc.info/?l=linux-wireless&m=127374343217011&w=2

---
Gertjan.
