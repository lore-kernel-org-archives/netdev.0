From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Tue, 10 Dec 2013 09:22:35 +0200
Message-ID: <CAJZOPZJJdc_r88Mp0Y5of42dG51yBnsrwVHyuGxzC_XCYXjPKg@mail.gmail.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
	<52A36235.1040406@cogentembedded.com>
	<1386440208.2195.3.camel@jtkirshe-mobl>
	<52A3812F.4070701@cogentembedded.com>
	<1386444985.2195.8.camel@jtkirshe-mobl>
	<52A39129.7090507@cogentembedded.com>
	<1386449757.2195.30.camel@jtkirshe-mobl>
	<CAJZOPZLiQO2jnX5mgi0C07GfE354VsqhoEdRHCEahZtPoB7d2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:36374 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab3LJHWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 02:22:36 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so7028187pbc.25
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 23:22:35 -0800 (PST)
In-Reply-To: <CAJZOPZLiQO2jnX5mgi0C07GfE354VsqhoEdRHCEahZtPoB7d2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 12:05 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Sat, Dec 7, 2013 at 10:55 PM, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>> On Sun, 2013-12-08 at 00:20 +0300, Sergei Shtylyov wrote:

>>>     Greg KH seems to be persistent in being negative towards its use. I also
>>> react semi-automatically whenever I see it, asking to remove it. Anyway, it's
>>> really DaveM's issue whether to allow it.
>>>     The main issue with it is that it doesn't contain any useful information
>>> to an ordinary person browsing kernel commits, it's exactly for the internal use only.

>> Well, I would disagree on the point that it would be for internal use
>> only.  While it is a internal git hash, it helps us support the Linux
>> community by helping us track the internal history of the patch for
>> support and changes.  So customers could give us either the Linux kernel
>> hash (in which turn we would find the internal hash id information from
>> the patch description) or could give us the I<hash>.  So you are right,
>> we would be the ones using the information to help support you and
>> everyone else.

> Shouldn't vendors actually seek to do that  the other way around? e.g
> find a way to link plain upstream commit Hash to their feature request
> / bug reports / development trees and not plant the IHash on upstream? just thinking out loud.


e.g what's wrong with having the maintainer of the internal git tree
do "git reword" for the internal
commit after it has been accepted into upstream and adding there the
upstream hash. This will
create a link with the Internal Change-Id: w.o putting vendors'
change-Id: on upstream commits, thoughts?

Or.
