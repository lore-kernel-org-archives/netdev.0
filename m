From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [RFC PATCH net-next] switchdev: Enable HW offloading of fdb add/delete
 on team devices.
Date: Tue, 31 Mar 2015 11:41:18 -0700
Message-ID: <551AEA4E.9020305@intel.com>
References: <1427748998-14346-1-git-send-email-sridhar.samudrala@intel.com> <CAE4R7bCG24SrzLFezCuB7OVbds9qaSegT-w-Dud3+V4Yz=SoRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	sfeldman@gmail.com, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23049 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835AbbCaSlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 14:41:18 -0400
In-Reply-To: <CAE4R7bCG24SrzLFezCuB7OVbds9qaSegT-w-Dud3+V4Yz=SoRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/2015 9:16 AM, Scott Feldman wrote:
> Hi Sridhar,
>
> Thanks for working on this.  It looks good to me.  But, this is an
> example of the ops code exposition I was trying to address in my swdev
> attrs patch.  I'll planning on sending a v2 for that patch set
> tonight, and I think you'll see adding your work for FDB add/del over
> stacked drivers will just fall out with just a little bit of new code.
> I hope you would resend this patch based on my v2?
Sure. Will look into your v2 patch and resend based on that patch and 
also will
see if i can include fdb dump support.

>
> BTW, swdev attrs is what I had in v1. What's coming in v2 in addition
> to swdev attrs and swdev objs, to support things that are objects and
> not attributes, like VLANs, FDB entries, FIB entries.  Hopefully it
> makes sense when you see it.
>
> -scott
>
>
