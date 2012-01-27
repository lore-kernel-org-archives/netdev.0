From: isshed <isshed.sip@gmail.com>
Subject: Re: [Ipsec-tools-devel] ipsec
Date: Fri, 27 Jan 2012 17:17:08 +0530
Message-ID: <CAGntp_96BDQ94yKFXBRLGwp4T5euQdz2=WgtoTD2aiHSs53UCA@mail.gmail.com>
References: <CAGntp_9230BjQMLzP=w_Cis-Ct3i5iGzq+FXaGvuOBCt4LCMTg@mail.gmail.com>
	<zarafa.4f1e83f3.54e5.3feb0c7b58dba4c8@zarafa.cubewerk.int>
	<CAGntp_9viJrdb6-8RuCu5YsgMEdeh3iwKZ2i4_6yoXFbBS9L1Q@mail.gmail.com>
	<CAAteiHa48jAT4Exr-FN49w8XhduFTCz0Y=6khO36wm3N9azYkA@mail.gmail.com>
	<CAGntp_9qN5GpzDMt1C3qcknEK+TzSVz3d2LFXVvnAZ4-sKHRGA@mail.gmail.com>
	<CAAteiHZaMcqmv2YJsixoycKZhjLLFciVZWD+Szc2=CGN7XTpWQ@mail.gmail.com>
	<CAGntp_8RoPhhWWmUA8JY6g+iWaecNECRp1FduLc19rXGjx+ECA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ipsec-tools-devel@lists.sourceforge.net"
	<ipsec-tools-devel@lists.sourceforge.net>, netdev@vger.kernel.org
To: Kimmo Koivisto <koippa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:43880 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580Ab2A0LrK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 06:47:10 -0500
Received: by vcbgb30 with SMTP id gb30so1102703vcb.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 03:47:09 -0800 (PST)
In-Reply-To: <CAGntp_8RoPhhWWmUA8JY6g+iWaecNECRp1FduLc19rXGjx+ECA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46YI...

On 1/27/12, isshed <isshed.sip@gmail.com> wrote:
> kernel-headers-2.6.23.1-42.fc8.i386.rpm is the rpm I installed but
> still i am facinf the same issue. After installation this rpm I can
> locate this file /usr/include/linux/pfkeyv2.h.
>
> but the expected location is /usr/include/net/.
>
> Is there any other rpm I need to install?
>
> Thanks.
>
> On 1/25/12, Kimmo Koivisto <koippa@gmail.com> wrote:
>> Hello
>>
>> You can manually install rpm-files from the original installation
>> media, if you have installed your Fedora from physical media and not
>> from internet.
>>
>> I'm not using Fedora and thus don't really know the correct rpm file
>> names. You can locate the nearest download site from
>> http://mirrors.fedoraproject.org/publiclist/ and then find the corre=
ct
>> kernel-header rpm file.
>> For example, for Fedora 16 on i386, I could use mirror from
>> http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/fedora/lin=
ux/releases/16/Fedora/i386/os/Packages/
>> and I would download kernel and kernel-headers.
>> Or better way is to download the whole installation media, then you
>> would have complete set on rpm files to use, you might need some oth=
er
>> rpm files on your way to the top :)
>>
>> Best Regards,
>> Kimmo
>>
>> 2012/1/25 isshed <isshed.sip@gmail.com>:
>>> Thanks Kimmo,
>>>
>>> Is there any other way because I do not have internet access on thi=
s
>>> machine..If i know the package name(rpm).I can get it from internet=
 on
>>> some other machine connected to internet and could install it.
>>>
>>> Thanks,
>>>
>>> On 1/25/12, Kimmo Koivisto <koippa@gmail.com> wrote:
>>>> Hello
>>>>
>>>> I think you should install kernel headers:
>>>>
>>>> yum install kernel-headers
>>>>
>>>> Best Regards,
>>>> Kimmo
>>>>
>>>> 2012/1/24 isshed <isshed.sip@gmail.com>:
>>>>> Thanks Stefan!
>>>>>
>>>>> But my question is how do I get this header file? Is there any
>>>>> package I need to install on my machine? I am using fedora linux.
>>>>>
>>>>> Thanks Again!
>>>>>
>>>>>
>>>>> On 1/24/12, Stefan Bauer <stefan.bauer@cubewerk.de> wrote:
>>>>>> -----Urspr=FCngliche Nachricht-----
>>>>>> Von:  isshed <isshed.sip@gmail.com>
>>>>>> Gesendet:     Di 24.01.2012 10:20
>>>>>> Betreff:      [Ipsec-tools-devel] ipsec
>>>>>> An:   ipsec-tools-devel@lists.sourceforge.net;
>>>>>>> Hi All,
>>>>>>>
>>>>>>> Sorry to bother you but I am sure many of you are implementing =
the
>>>>>>> IPsec. I am very new to this technology. Today I was writing a
>>>>>>> simple
>>>>>>> program of key management using PF_KEY sockets.Basically I
>>>>>>> downloaded
>>>>>>> unixnetworkprograming books example from internet. while compil=
ing I
>>>>>>> am getting the following error...
>>>>>>>
>>>>>>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>>>>>> gcc -I../lib -g -O2 -D_REENTRANT -Wall   -c -o dump.o dump.c
>>>>>>> In file included from dump.c:1:
>>>>>>> unp.h:122: error: redefinition of =E2struct in_pktinfo=E2
>>>>>>> dump.c:2:25: error: net/pfkeyv2.h: No such file or directory
>>>>>>
>>>>>> You simply lack net/pfkeyv2.h
>>>>>>
>>>>>> Stefan
>>>>>>
>>>>>> ----------------------------------------------------------------=
--------------
>>>>>> Keep Your Developer Skills Current with LearnDevNow!
>>>>>> The most comprehensive online learning library for Microsoft
>>>>>> developers
>>>>>> is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS=
3,
>>>>>> MVC3,
>>>>>> Metro Style Apps, more. Free future releases when you subscribe =
now!
>>>>>> http://p.sf.net/sfu/learndevnow-d2d
>>>>>> _______________________________________________
>>>>>> Ipsec-tools-devel mailing list
>>>>>> Ipsec-tools-devel@lists.sourceforge.net
>>>>>> https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel
>>>>>>
>>>>>
>>>>> -----------------------------------------------------------------=
-------------
>>>>> Keep Your Developer Skills Current with LearnDevNow!
>>>>> The most comprehensive online learning library for Microsoft
>>>>> developers
>>>>> is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3=
,
>>>>> MVC3,
>>>>> Metro Style Apps, more. Free future releases when you subscribe n=
ow!
>>>>> http://p.sf.net/sfu/learndevnow-d2d
>>>>> _______________________________________________
>>>>> Ipsec-tools-devel mailing list
>>>>> Ipsec-tools-devel@lists.sourceforge.net
>>>>> https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel
>>>>
>>>> ------------------------------------------------------------------=
------------
>>>> Keep Your Developer Skills Current with LearnDevNow!
>>>> The most comprehensive online learning library for Microsoft devel=
opers
>>>> is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3,
>>>> MVC3,
>>>> Metro Style Apps, more. Free future releases when you subscribe no=
w!
>>>> http://p.sf.net/sfu/learndevnow-d2d
>>>> _______________________________________________
>>>> Ipsec-tools-devel mailing list
>>>> Ipsec-tools-devel@lists.sourceforge.net
>>>> https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel
>>>>
>>
>> --------------------------------------------------------------------=
----------
>> Keep Your Developer Skills Current with LearnDevNow!
>> The most comprehensive online learning library for Microsoft develop=
ers
>> is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, M=
VC3,
>> Metro Style Apps, more. Free future releases when you subscribe now!
>> http://p.sf.net/sfu/learndevnow-d2d
>> _______________________________________________
>> Ipsec-tools-devel mailing list
>> Ipsec-tools-devel@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel
>>
>
