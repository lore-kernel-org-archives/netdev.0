From: Douglas Leith <doug.leith@nuim.ie>
Subject: Re: Re the default linux tcp algorithm being changed from bic to cubic.
Date: Thu, 28 Sep 2006 17:20:46 +0100
Message-ID: <451BF65E.9000701@nuim.ie>
References: <451B9ED6.9090208@nuim.ie> <20060928071657.5d0cbf70@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:30187 "EHLO LARCH.MAY.IE")
	by vger.kernel.org with ESMTP id S1751921AbWI1QWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 12:22:21 -0400
Received: from [192.168.0.2] ([212.2.174.101])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01M7QIRVM69A00WT0K@NUIM.IE>
 for netdev@vger.kernel.org; Thu, 28 Sep 2006 17:22:30 +0000 (GMT)
In-reply-to: <20060928071657.5d0cbf70@freekitty>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 28 Sep 2006 11:07:18 +0100
> Douglas Leith <doug.leith@nuim.ie> wrote:
> 
>> Content-Type: text/plain; charset=UTF-8; format=flowed
>> Content-Transfer-Encoding: 7bit
>>
>> Steve,
>>
>> I think we're all conscious of the fact that recent history contains 
>> quite a number of proposals for changes to tcp's congestion control 
>> algorithm for high bandwidth-delay product paths that on closer 
>> inspection have proved problematic in one way or another.   It seems to 
>> be a hard problem to solve, so maybe that's fair enough and hopefully 
>> we'll end up with a workable solution soon.
>>
>> Where I'm coming from here though is that bic was made the linux default 
>> a year or so ago at a time when there were essentially no tests 
>> available on its performance other than the infocom paper by Injong. 
>> Subsequent tests have since highlighted a bunch of issues with bic.  To 
>> my knowledge, we're currently in a similar situation with cubic as we 
>> were with bic back then i.e. essentially no independent tests 
>> investigating its behaviour.
>>
>> Of course I know Injong has posted some test results, but these are 
>> hardly independent as he's the author of both bic and cubic.  Have there 
>> perhaps been private tests carried out (e.g. by osdl) ?  If so, would it 
>> be possible to make them public ?  If not, well that would be good to 
>> know too.
> 
> My tests have been limited and showed no difference. It is worthy
> of more discussion as to what is best. Could you rerun your tests?

Unfortunately we haven't really looked at cubic at all to date as I 
didn't appreciate it was being seriously considered for the new default 
until Ian's post a few days ago.  It'll take a little time to free up 
some bandwidth in people's time here, but we'd be happy to rerun the 
previous tests with cubic as a priority and generally try to have an 
initial poke around.

Doug

Hamilton Institute
www.hamilton.ie
