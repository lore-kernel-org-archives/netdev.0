From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Thu, 27 Jul 2006 08:28:00 -0700
Message-ID: <44C8DB80.6030007@us.ibm.com>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru>	 <20060726100431.GA7518@infradead.org> <20060726101919.GB2715@2ka.mipt.ru>	 <20060726103001.GA10139@infradead.org> <44C77C23.7000803@redhat.com>	 <44C796C3.9030404@us.ibm.com> <1153982954.3887.9.camel@frecb000686>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Suparna Bhattacharya <suparna@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:24779 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932548AbWG0P2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 11:28:06 -0400
To: =?ISO-8859-15?Q?S=E9bastien_Dugu=E9?= <sebastien.dugue@bull.net>
In-Reply-To: <1153982954.3887.9.camel@frecb000686>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

S=E9bastien Dugu=E9 wrote:
> On Wed, 2006-07-26 at 09:22 -0700, Badari Pulavarty wrote:
>  =20
>> Ulrich Drepper wrote:
>>    =20
>>> Christoph Hellwig wrote:
>>>  =20
>>>      =20
>>>>> My personal opinion on existing AIO is that it is not the right d=
esign.
>>>>> Benjamin LaHaise agree with me (if I understood him right),
>>>>>      =20
>>>>>          =20
>>>> I completely agree with that aswell.
>>>>    =20
>>>>        =20
>>> I agree, too, but the current code is not the last of the line.  Su=
parna
>>> has a st of patches which make the current kernel aio code work muc=
h
>>> better and especially make it really usable to implement POSIX AIO.
>>>
>>> In Ottawa we were talking about submitting it and Suparna will.  We=
 just
>>> thought about a little longer timeframe.  I guess it could be
>>> accelerated since he mostly has the patch done.  But I don't know h=
er
>>> schedule.
>>>
>>> Important here is, don't base any decision on the current aio
>>> implementation.
>>>  =20
>>>      =20
>> Ulrich,
>>
>> Suparna mentioned your interest in making POSIX glibc aio work with=20
>> kernel-aio at OLS.
>> We thought taking a re-look at the (kernel side) work BULL did, woul=
d be=20
>> a nice starting
>> point. I re-based those patches to 2.6.18-rc2 and sent it to Zach Br=
own=20
>> for review before
>> sending them out to list.
>>
>> These patches does NOT make AIO any cleaner. All they do is add=20
>> functionality to support
>> POSIX AIO easier. These are
>>
>> [ PATCH 1/3 ]  Adding signal notification for event completion
>>
>> [ PATCH 2/3 ]  lio (listio) completion semantics
>>
>> [ PATCH 3/3 ] cancel_fd support
>>    =20
>
>   Badari,
>
>   Thanks for refreshing those patches, they have been sitting here
> for quite some time now and collected dust.
>
>   I also think Suparna's patchset for doing buffered AIO would be
> a real plus here.
>
>  =20
>> Suparna explained these in the following article:
>>
>> http://lwn.net/Articles/148755/
>>
>> If you think, this is a reasonable direction/approach for the kernel=
 and=20
>> you would take care
>> of glibc side of things - I can spend time on these patches, getting=
=20
>> them to reasonable shape
>> and push for inclusion.
>>    =20
>
>   Ulrich, I you want to have a look at how those patches are put to
> use in libposix-aio, have a look at http://sourceforge.net/projects/p=
aiol.
>
>   It could be a starting point for glibc.
>
>   Thanks,
>
>   S=E9bastien.
>
>  =20
Sebastien,

Suparna mentioned at Ulrich wants us to concentrate on kernel-side=20
support, so that he
can look at glibc side of things (along with other work he is already=20
doing). So, if we
can get an agreement on what kind of kernel support is needed - we can=20
focus our
efforts on kernel side first and leave glibc enablement to capable hand=
s=20
of Uli :)

Thanks,
Badari

