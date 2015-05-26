From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Tue, 26 May 2015 11:40:31 -0500
Message-ID: <5564A1FF.8080301@lwfinger.net>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net> <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com> <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda> <1432575448.2846.63.camel@perches.com> <20150526044611.GA3465@sudip-PC> <1432616108.2846.83.camel@perches.com> <20150526050212.GC3465@sudip-PC> <1432616879.2846.86.camel@perches.com> <20150526141401.GC21573@kroah.com> <20150526154826.GJ11588@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	devel@driverdev.osuosl.org,
	Sudip Mukherjee <sudip@vectorindia.org>,
	linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
	netdev@vger.kernel.org, Haggai Eran <haggai.eran@gmail.com>,
	Arek Rusniak <arek.rusi@gmail.com>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33886 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbbEZQkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 12:40:35 -0400
In-Reply-To: <20150526154826.GJ11588@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2015 10:48 AM, Dan Carpenter wrote:
> On Tue, May 26, 2015 at 07:14:01AM -0700, Greg KH wrote:
>> I take the blame for any problems with Outreachy patches.  Given the
>> huge volume of them, one bug out of 900 isn't that bad of a percentage.
>
> We don't get many bugs through outreachy, but this isn't the first one.
> For example, in March and April people complained about:
>
> 95745e9b1de2 ('staging: lustre: Use kasprintf.')
> 45de432775d6 ('Staging: rtl8712: Use memdup_user() instead of copy_from_user()')
>
> There have been others but I have a short memory.  We have this
> discussion every time.  How come no one caught this bug in review??  Oh,
> it never went through the list.
>
> I'm fine with 5 bugs per 900 patches or whatever.  I wish that the
> patches came to the list, but I get that that would double your review
> workload to review 900 patches on the outreachy list and again on the
> normal dev list.

Adding the maintainer to the original list would still be a good step. I'm not 
sure that I would have caught "rtl8712: Use memdup_user() instead of 
copy_from_user()" in review, but I certainly would have seen that it was not 
proper to do a blanket substitution of del_timer_sync() for a wrapper that used 
del_timer().

Obviously the awful coding in rtl8712 contains more traps to trick the novices 
than does most code. It also predates a lot of changes in checkpatch.pl and 
contains a lot of low-hanging fruit.

Larry
