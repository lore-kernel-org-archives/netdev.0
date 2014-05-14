From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Problem with iflink in netns
Date: Tue, 13 May 2014 17:51:18 -0700
Message-ID: <20140513175118.1e6bc156@nehalam.linuxnetplumber.net>
References: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
	<CAHA+R7NX8BoXHkSZ97+op7Leg3nD_=TFjJ1K3wSr3pWQbF4Eug@mail.gmail.com>
	<20140513130554.2e452af8@nehalam.linuxnetplumber.net>
	<CAHA+R7P_MBrPLVqtvCnC+bPkQ7FHRiLgi0zHAQkz5-9_Z1MBJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:46237 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbaENAvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 20:51:22 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so923250pab.14
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 17:51:21 -0700 (PDT)
In-Reply-To: <CAHA+R7P_MBrPLVqtvCnC+bPkQ7FHRiLgi0zHAQkz5-9_Z1MBJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 May 2014 13:44:24 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Tue, May 13, 2014 at 1:05 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> >
> > That won't solve the problem.
> >  1. a pointer increase size of netns and requires refcount
> 
> Yes.
> 
> >  2. iflink is still exposed in kernel user API and has to be set
> >     otherwise the device is falsely reported.
> 
> Then report 0 which is not a valid ifindex?

But that is what devices without a parent report.
