From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: bpf filter : support for vlan tag
Date: Tue, 16 Oct 2012 13:34:56 +0200
Message-ID: <CAD6jFUTEH9G9mgzn2XAmHj2vkOUkZ5RNitfHnGWXyjv-V_UStw@mail.gmail.com>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	<1350369998.3954.563.camel@edumazet-glaptop>
	<CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	<1350386917.3954.890.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34824 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515Ab2JPLfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 07:35:04 -0400
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TO5QN-00083S-3H
	for netdev@vger.kernel.org; Tue, 16 Oct 2012 13:35:03 +0200
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLSv1:RC4-SHA:128)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TO5QN-0003hv-Di
	for netdev@vger.kernel.org; Tue, 16 Oct 2012 13:35:03 +0200
Received: by mail-ea0-f174.google.com with SMTP id c13so1448091eaa.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 04:34:56 -0700 (PDT)
In-Reply-To: <1350386917.3954.890.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 1:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-10-16 at 13:00 +0200, Daniel Borkmann wrote:
>> On Tue, Oct 16, 2012 at 8:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2012-10-15 at 19:10 -0700, Ani Sinha wrote:
>> >> Hi :
>> >>
>> >> I was looking at the kernel side implementation of the BPF filter. I
>> >> do not see any code that supports filtering of packets based on
>> >> provided vlan tag information from the skbuff. This will make it
>> >> impossible to provide any filter to tcpdump that will filter packets
>> >> based on the tag information if libpcap uses the kernel filter.
>> >>
>> >> Any help will be much appreciated.
>> >
>> > Right, we need a basic support, using a new ancillary definition.
>> >
>> > Is the following patch enough to address your need, or do you also need
>> > access to vlan_tx_tag_present() ?
>>
>> I like this patch, it's especially useful to speed up processing for
>> packet analyzers. vlan_tx_tag_present() might also be good to have if
>> this doesn't waste to much room for future ancillary operations.
>
> There is plenty of room in ancillary space
>
> Note that if speed is needed, we also want to update various JIT
> implementations.

Thanks for the patch. My kernel was still compiling and mutt was
already open for a submission on the vlan_tx_tag_present() operation.
:-)
