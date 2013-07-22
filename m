From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH iproute2 1/2] ss: Fix compiler errors of unused return-values
Date: Mon, 22 Jul 2013 19:06:11 +0400
Message-ID: <CAHj3AVnrAvCZvzY00qsQodwyXSLF28bPWFJhRTnd5Ny=kZHyZA@mail.gmail.com>
References: <1374350298-1177-1-git-send-email-christoph.paasch@uclouvain.be>
	<1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
	<20130722075410.78532ad4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:49044 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767Ab3GVPGM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:06:12 -0400
Received: by mail-ea0-f175.google.com with SMTP id z7so3844362eaf.6
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:06:11 -0700 (PDT)
In-Reply-To: <20130722075410.78532ad4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do we need the -Werror at all? I've found a similar discussion
regarding building wil6210 driver with the same issue

On 7/22/13, Stephen Hemminger <stephen@networkplumber.org> wrote:
> On Sat, 20 Jul 2013 21:58:17 +0200
> Christoph Paasch <christoph.paasch@uclouvain.be> wrote:
>
>> Many errors when compiling with gcc 4.7.3 about unused return-values
>> upon the calls to fgets and fscanf:
>>
>> ss.c: In function =91user_ent_hash_build=92:
>> ss.c:305:12: error: ignoring return value of =91fscanf=92, declared =
with
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> ss.c: In function =91get_slabstat=92:
>> ss.c:387:7: error: ignoring return value of =91fgets=92, declared wi=
th
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> ss.c: In function =91init_service_resolver=92:
>> ss.c:511:8: error: ignoring return value of =91fgets=92, declared wi=
th
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> ss.c: In function =91run_ssfilter=92:
>> ss.c:728:11: error: ignoring return value of =91fscanf=92, declared =
with
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> ss.c: In function =91is_ephemeral=92:
>> ss.c:550:10: error: ignoring return value of =91fscanf=92, declared =
with
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> ss.c: In function =91netlink_show=92:
>> ss.c:2836:7: error: ignoring return value of =91fgets=92, declared w=
ith
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> ss.c: In function =91packet_show=92:
>> ss.c:2630:7: error: ignoring return value of =91fgets=92, declared w=
ith
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> ss.c: In function =91unix_show=92:
>> ss.c:2364:7: error: ignoring return value of =91fgets=92, declared w=
ith
>> attribute warn_unused_result [-Werror=3Dunused-result]
>> cc1: all warnings being treated as errors
>> make[1]: *** [ss.o] Error 1
>> make[1]: Leaving directory
>> `/home/christoph/workspace/linux/iproute2/misc'
>> make: *** [all] Error 2
>>
>> For the calls to fscanf we can't really do anything about it, and ju=
st
>> do an empty if-statement to make the compiler happy.
>>
>>
>
> I would prefer an error message rather than silently exiting.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--=20
Regards,
Denis
