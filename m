From: Christian Riesch <christian.riesch@gmail.com>
Subject: Re: [PATCH net-next 2/2] ptp: Fix compiler warnings in the testptp
 utility
Date: Wed, 09 Apr 2014 08:23:56 +0200
Message-ID: <E5D957FE6841B1A8773B909A@[172.22.2.41]>
References: <1395746646-28299-1-git-send-email-christian.riesch@omicron.at>
 <a2330f7d-0abf-4ee0-9288-1e881b2b5368@mary.at.omicron.at>
 <20140325114523.GB14836@netboy>
 <1396993385.2376.8.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org, Dong Zhu <bluezhudong@gmail.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:54213 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaDIGYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 02:24:01 -0400
Received: by mail-ee0-f54.google.com with SMTP id d49so1459921eek.27
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 23:24:00 -0700 (PDT)
In-Reply-To: <1396993385.2376.8.camel@jekeller-desk1.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On April 08, 2014 21:43 +0000 "Keller, Jacob E" 
<jacob.e.keller@intel.com> wrote:

> On Tue, 2014-03-25 at 12:45 +0100, Richard Cochran wrote:
>> On Tue, Mar 25, 2014 at 12:24:06PM +0100, Christian Riesch wrote:
>> > Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>> > Cc: Dong Zhu <bluezhudong@gmail.com>
>> > ---
>> >  Documentation/ptp/testptp.c |   10 +++++-----
>> >  1 file changed, 5 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
>> > index 13bddd5..14bf19e 100644
>> > --- a/Documentation/ptp/testptp.c
>> > +++ b/Documentation/ptp/testptp.c
>> > @@ -496,14 +496,14 @@ int main(int argc, char *argv[])
>> >  			interval = t2 - t1;
>> >  			offset = (t2 + t1) / 2 - tp;
>> >
>> > -			printf("system time: %ld.%ld\n",
>> > +			printf("system time: %lld.%u\n",
>> >  				(pct+2*i)->sec, (pct+2*i)->nsec);
>> > -			printf("phc    time: %ld.%ld\n",
>> > +			printf("phc    time: %lld.%u\n",
>> >  				(pct+2*i+1)->sec, (pct+2*i+1)->nsec);
>> > -			printf("system time: %ld.%ld\n",
>> > +			printf("system time: %lld.%u\n",
>> >  				(pct+2*i+2)->sec, (pct+2*i+2)->nsec);
>> > -			printf("system/phc clock time offset is %ld ns\n"
>> > -				"system     clock time delay  is %ld ns\n",
>>
>> Use PRId64 instead?
>>
>> Thanks,
>> Richard
>>
>
> I agree with this. %lld is not going to resolve the error properly on a
> 32 bit machine.

Actually, %lld solves the problem on a 32 bit machine (this is what I am 
compiling for), but it will cause warnings on 64 bit, right?
Christian
