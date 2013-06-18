From: Jason Wang <jasowang@redhat.com>
Subject: Re: Patches required for 3.9 stable
Date: Tue, 18 Jun 2013 12:42:41 +0800
Message-ID: <51BFE541.3020407@redhat.com>
References: <51BEC1C3.40109@redhat.com> <20130617152909.GA20663@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, jwboyer@redhat.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977Ab3FREm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 00:42:57 -0400
In-Reply-To: <20130617152909.GA20663@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2013 11:29 PM, Greg KH wrote:
> On Mon, Jun 17, 2013 at 03:58:59PM +0800, Jason Wang wrote:
>> Hi Greg:
>>
>> Please include the following commits into 3.9.y. Which fixes:
>>
>> 1) Crash when sending GSO packets from untrusted sources
>> 9b4d669bc06c215d64f56f1eb0d4eb96e14d689d
>> 38502af77e07b5d6650b9ff99a0b482d86366592
>> c1aad275b0293d2b1905ec95a945422262470684
>> f9ca8f74399f9195fd8e01f67a8424a8d33efa55
>> 15e5a030716468dce4032fa0f398d840fa2756f6
>>
>> 2) Can't create a multiqueue tap
>> e8dbad66ef56074eadb41ed5998acd2320447018
>>
>> All can be cheery-picked and I have tested them.
> Then please work with the network maintainer, as he has a separate
> stable queue that he tests and then sends to me, I do not apply stable
> patches directly for the network subsystem.

Get it.
> Have you looked at the stable patchwork queue to verify that these are
> not in there already?

These are not in.
>
> thanks,
>
> greg k-h
