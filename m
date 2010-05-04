From: Bhaskar Dutta <bhaskie@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Tue, 4 May 2010 19:58:32 +0530
Message-ID: <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:33374 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345Ab0EDO2f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 10:28:35 -0400
Received: by pvg12 with SMTP id 12so17248pvg.19
        for <netdev@vger.kernel.org>; Tue, 04 May 2010 07:28:34 -0700 (PDT)
In-Reply-To: <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 4, 2010 at 5:02 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Tue, 2010-05-04 at 09:00 +0530, Bhaskar Dutta wrote:
>> Hi,
>>
>> I am observing intermittent TCP-MD5 checksum failures
>> (CONFIG_TCP_MD5SIG) =A0on kernel 2.6.31 while talking to a BGP route=
r.
>>
>> The problem is only seen in multi-core 64 bit machines.
>> Is there any known bug in the per_cpu_ptr implementation (I am aware
>> that the percpu allocator has been re-implemented in 2.6.33) that
>> might cause a corruption in 64 bit SMP machines?
>>
>> Any pointers would be appreciated.
>
> There was another recent report of incorrect MD5 signatures in
> <http://thread.gmane.org/gmane.linux.network/159556>, but without any
> response.
>
> Ben.
>

I found another thread posted back in Jan 2007 with a similar bug
(x86_64 on 2.6.20) but no replies to that as well.
http://lkml.org/lkml/2007/1/20/56

Bhaskar
