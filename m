From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- experimental revert for 2.6.27 failed
Date: Wed, 13 Aug 2008 09:05:05 -0700
Message-ID: <86802c440808130905s360c9695jef64b6ed7746899@mail.gmail.com>
References: <108777.49875.qm@web82104.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.251]:18273 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbYHMQFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 12:05:06 -0400
Received: by hs-out-0708.google.com with SMTP id 4so30640hsl.5
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 09:05:05 -0700 (PDT)
In-Reply-To: <108777.49875.qm@web82104.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 5:03 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
>
>> please try attached patch with 2.6.27-rc3
>
> Thx for the patch... and for providing it as an attachment.  My email
> situation is less than optimal, and I am stuck using my ISP's web
> interface for the present.
>
> I used 'git apply --check <patchfilename>' first, and got no errors, so
> I applied it, built, installed, and rebooted.

could apply with
cat revert_*.;patch | patch -p1

YH
