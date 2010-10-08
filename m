From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 19:47:51 +0200
Message-ID: <4CAF5947.3090803@free.fr>
References: <201010071048.12817.hans.schillstrom@ericsson.com> <4CAEFE2C.3010007@free.fr>	<201010081353.28056.hans.schillstrom@ericsson.com> <201010081428.37639.hans.schillstrom@ericsson.com>	<4CAF3E78.8030202@free.fr> <4CAF4408.6070001@free.fr> <m1k4ls1v1i.fsf@fess.ebiederm.org> <4CAF54E2.20204@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:35441 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759050Ab0JHRr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:47:57 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o98Hluvr005040
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 17:47:56 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o98HluEE3920116
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 18:47:56 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o98Hlt0C026318
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 18:47:55 +0100
In-Reply-To: <4CAF54E2.20204@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2010 07:29 PM, Daniel Lezcano wrote:
> On 10/08/2010 06:58 PM, Eric W. Biederman wrote:
>> Daniel Lezcano<daniel.lezcano@free.fr> writes:
>>
>>> On 10/08/2010 05:53 PM, Daniel Lezcano wrote:
>>>> On 10/08/2010 02:28 PM, Hans Schillstrom wrote:
>>>>> Hi Eric,
>>>>> Any advice how to trace this down ?
>>>>> This rollback_registered_many() seems to have on the lists before=
=2E..
>>>>> All IPv4 and IPv6 tunnels causes this crash, all you have to do i=
s
>>>>> load the tunnel module(s)
>>>>> enter a new ns and exit from it.
>>>>>
>>>>> Have not tested any more devices than tunnels,
>>>>> I did an "ip link delete" on my macvlans before exiting the ns.
>>>> Ah ! I succeed to reproduce it.
>>>> It does not appear immediately in fact.
>>>>
>>>> I am trying to simplify the configuration but I am falling in the =
bug I
>>>> talked about in the previous email.
>>> Ok, so after investigating, we just need a macvlan and specify an
>>> ipv6 address
>>> for it (inside a new netns of course), and the loopback is not
>>> released. I
>>> compiled out the tunnels, so they are not related to this problem I
>>> think.
>>>
>>> That reduces the scope of investigation :)
>> This reproduces the unable to free nedevice problem? Or the bad
>> pointer in macvlan_close problem?
>
> The free netdevice problem.
>
> For the macvlan problem, you have to create 2 macvlans on the *same*

Just to clarify. The problem happens with a different macvlans on=20
different physical interfaces but it is harder to reproduce.






















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92=
400
Courbevoie
RCS Nanterre 552 118 465
=46orme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
