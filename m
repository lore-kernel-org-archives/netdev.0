From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: team: expose sysfs attributes for each team option
Date: Wed, 19 Nov 2014 20:17:01 +0100
Message-ID: <546CECAD.1040402@redhat.com>
References: <93856491220bda9aede41a9571fb1ac1.squirrel@www.codeaurora.org> <20141117130201.GB1872@nanopsycho.orion> <03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org> <CAHA+R7OOnSfSP1uHrg=osH=+=sb-0Zj-=yYx8HXmpO95v+Dhyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hamad Kadmany <hkadmany@codeaurora.org>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	tgraf@suug.ch
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756021AbaKSTRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 14:17:33 -0500
In-Reply-To: <CAHA+R7OOnSfSP1uHrg=osH=+=sb-0Zj-=yYx8HXmpO95v+Dhyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2014 07:45 PM, Cong Wang wrote:
> On Wed, Nov 19, 2014 at 4:28 AM, Hamad Kadmany <hkadmany@codeaurora.org> wrote:
>> On Mon, November 17, 2014 1:02 pm, Jiri Pirko wrote:
>>>
>>> Nak.
>>>
>>> I don't like this patch. The plan for team was keep things simple and to
>>> have single userspace api using netlink, as that is the correct way to
>>> deal with things. Sysfs for this use-case is not. Please, use netlink api.

+1

>> Using team driver requires using libnl3. In Android based platforms, libnl3
 >> is not supported, and libnl3 license poses constraints in Android's user-space.

Constraints?! libnl3 is LGPL ...

> Check if libmnl fits your license:
> http://www.netfilter.org/projects/libmnl/

... and this one, too.
