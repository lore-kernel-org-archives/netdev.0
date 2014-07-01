From: Tom Gundersen <teg@jklm.no>
Subject: Re: [systemd-devel] [PATCH] Use dev_port for the ID of a network device.
Date: Tue, 1 Jul 2014 14:45:56 +0200
Message-ID: <CAG-2HqUM6OSM4-4eVO4KuY38KpKiKTM_H6mdb775VXP+YVuUHg@mail.gmail.com>
References: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <CAPXgP13o=qZc0q+Af0sd6bLKUawKYw0L_SLqh3VgLZBJ1CfYSA@mail.gmail.com> <20140701123208.GC1204@oc0268524204.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kay Sievers <kay@vrfy.org>, netdev <netdev@vger.kernel.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f181.google.com ([209.85.128.181]:41935 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756141AbaGAMqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 08:46:17 -0400
Received: by mail-ve0-f181.google.com with SMTP id db11so9446428veb.40
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 05:46:16 -0700 (PDT)
In-Reply-To: <20140701123208.GC1204@oc0268524204.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 1, 2014 at 2:32 PM, Thadeu Lima de Souza Cascardo
<cascardo@linux.vnet.ibm.com> wrote:
> On Tue, Jul 01, 2014 at 02:33:19AM +0200, Kay Sievers wrote:
>> On Mon, Jun 30, 2014 at 10:36 PM, Thadeu Lima de Souza Cascardo
>> <cascardo@linux.vnet.ibm.com> wrote:
>> > For network devices on the same PCI function, dev_id should not be used,
>> > since its purpose is for IPv6 support on interfaces with the same MAC
>> > address.
>> >
>> > The new dev_port sysfs attribute should be used when it is found. When
>> > it is not, using dev_id might work.
>>
>> I don't see a problem switching this over, but why would we keep using
>> dev_id if it is not the right thing to use?
>>
>> Kay
>>
>
> Because dev_port has only been introduced into Linux 3.15, and some
> drivers used dev_id before Linux 3.10. It's not an ideal situation, so I
> think it's important to keep some compatibility for the time being. Or
> we could simply drop dev_id, and force everyone to do the right thing
> and backport dev_port support and fix their drivers.

If this fixes a real issue, I guess it would be nice to push the
dev_port stuff to -stable. If it is accepted it would solve the
backwards compatibility problem, and we could just drop dev_id from
udev.

Cheers,

Tom
