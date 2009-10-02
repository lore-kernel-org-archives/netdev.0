From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT-1: adding a sysctl
Date: Fri, 02 Oct 2009 17:46:12 -0400
Message-ID: <4AC674A4.2040900@gmail.com>
References: <4AC57AC5.3080703@gmail.com> <20091001225705.788d38ba@nehalam>	<4AC61505.8030701@gmail.com> <877hvdbj55.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:40731 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996AbZJBVqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 17:46:15 -0400
Received: by fxm27 with SMTP id 27so1451068fxm.17
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 14:46:19 -0700 (PDT)
In-Reply-To: <877hvdbj55.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> William Allen Simpson <william.allen.simpson@gmail.com> writes:
>> Any suggestions for improvement?  Or general approval?
> 
> The patch seems incomplete, can't find callers for most of the new functions.
> 
Ummm, I was following the suggested practice of breaking it into smaller
pieces for review.  This is just the control functions and headers.  I've
actually completed most of the port, and am champing at the bit.

I was hoping for concrete suggestions from the experienced Linux coders,
before submitting the rest of the code.


> In general cookies fell a bit out of favour because they don't support window
> scaling etc.  But you don't seem to fix that by putting that data into
> the new option.
> 
You mean DJB's "optionless" SYN cookies?  They saved everybody's bacon
back in the day, but that was when there were fewer options.  In 1996,
we all thought it was a quick hack on the way to a better solution.  But
the hack solved enough of the problem that nobody finished the work.

This option fixes (obviates and eventually obsoletes) SYN cookies, and
passes other options just fine.  That's one reason for doing it!

There should be a paper explaining in December's Usenix Login.  This is
the running code to go with the paper.


> My immediate gut reaction is that it will be likely challenging to 
> traverse many packet filters (which often have a tendency to drop
> anything they don't know) with this option on. That is also what killed
> ECN.
> 
Too true.  Not much we can do about it, but the various research surveys
suggest that an unknown option passes better....

