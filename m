From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 12/34] isdn/diva: Drop __TIME__ usage
Date: Thu, 26 May 2011 10:29:19 +0200
Message-ID: <4DDE0F5F.9080303@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz> <1302015561-21047-13-git-send-email-mmarek@suse.cz> <alpine.DEB.2.00.1104051709040.7262@justus.melware.de> <4DDD68C3.7000004@suse.cz> <alpine.DEB.2.00.1105261012360.20696@justus.melware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Armin Schindler <armin@melware.de>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1105261012360.20696@justus.melware.de>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26.5.2011 10:15, Armin Schindler wrote:
> On Wed, 25 May 2011, Michal Marek wrote:
>> Dne 5.4.2011 17:10, Armin Schindler napsal(a):
>>> On Tue, 5 Apr 2011, Michal Marek wrote:
>>>> The kernel already prints its build timestamp during boot, no need to
>>>> repeat it in random drivers and produce different object files each
>>>> time.
>>>
>>> The module can be build separately from the kernel, therefore it can have
>>> an own build timestamp.
>>
>> So the module timestamp and kernel timestamp vary by a couple of
>> minutes. But is it really a problem?
> 
> It could be a lot more than minutes. But it isn't a problem.
> I just tried to keep the sources in sync with out-of-tree version.
> 
>> I don't think so. So is there an
>> objection against applying this patch?
> 
> No objection. Please go ahead with the patch.

OK, thanks. Applied to kbuild-2.6.git#trivial.

Michal
