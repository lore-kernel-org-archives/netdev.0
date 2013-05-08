From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH RFC iproute2] Add VF link state control
Date: Wed, 08 May 2013 09:44:38 -0700
Message-ID: <518A80F6.5060605@intel.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>  <1368020717-22194-4-git-send-email-ogerlitz@mellanox.com>  <20130508091753.0be79e6c@nehalam.linuxnetplumber.net> <1368030286.1664.16.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43384 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756497Ab3EHQoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 12:44:54 -0400
In-Reply-To: <1368030286.1664.16.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/2013 9:24 AM, Dan Williams wrote:
> On Wed, 2013-05-08 at 09:17 -0700, Stephen Hemminger wrote:
>> On Wed,  8 May 2013 16:45:17 +0300
>> Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>
>>> From: Rony Efraim <ronye@mellanox.com>
>>>
>>> Add link state per VF command
>>>
>>> Signed-off-by: Rony Efraim <ronye@mellanox.com>
>>
>> Isn't this redundant with OPERSTATE and LOWER_DOWN?
>
> I was going to say it was mostly redundant with the "set carrier from
> userspace" patches from jpirko last December, but since a VF doesn't
> appear to always have a netdev, it seems that functionality has to be
> special-cased for VFs instead of being generic :(
>
> Dan
>

Or the netdev is direct assigned to some VM/namespace or otherwise out
of scope.

It does seem unfortunate though that every time we want a feature that
already exists to be applicable for a VF we have to go through this
exercise of adding an ndo op and adding lookup code in each and
every driver to find the VF and pass messages back and forth.

.John

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
