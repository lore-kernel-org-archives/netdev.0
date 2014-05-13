From: Cong Wang <cwang@twopensource.com>
Subject: Re: Problem with iflink in netns
Date: Tue, 13 May 2014 13:44:24 -0700
Message-ID: <CAHA+R7P_MBrPLVqtvCnC+bPkQ7FHRiLgi0zHAQkz5-9_Z1MBJA@mail.gmail.com>
References: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
	<CAHA+R7NX8BoXHkSZ97+op7Leg3nD_=TFjJ1K3wSr3pWQbF4Eug@mail.gmail.com>
	<20140513130554.2e452af8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35472 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaEMUoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 16:44:25 -0400
Received: by mail-la0-f53.google.com with SMTP id ec20so714589lab.40
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 13:44:24 -0700 (PDT)
In-Reply-To: <20140513130554.2e452af8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 1:05 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> That won't solve the problem.
>  1. a pointer increase size of netns and requires refcount

Yes.

>  2. iflink is still exposed in kernel user API and has to be set
>     otherwise the device is falsely reported.

Then report 0 which is not a valid ifindex?
