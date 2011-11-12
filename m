From: "Roland Kletzing" <devzero@web.de>
Subject: Re: send/receive data via eth0/1 external loop ?
Date: Sun, 13 Nov 2011 00:15:40 +0100 (CET)
Message-ID: <1917296016.1454031.1321139740439.JavaMail.fmail@mwmweb017>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Julian Anastasov" <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate04.web.de ([217.72.192.242]:47201 "EHLO
	fmmailgate04.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab1KLXPl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 18:15:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to confirm: IT WORKS! (tested with 2.6.38 kernel)=C2=A0 :)

more detail:
>> You can use accept_local flag and rule with pref 0:
>>
>>http://marc.info/?l=3Dlinux-netdev&m=3D125983955627148&w=3D2

this in itself is not enought to get it running, but with this one
http://marc.info/?l=3Dlinux-netdev&m=3D129500124207256&w=3D2
(adapted for eth0/1), it looks good=C2=A0 and i see packets flow betwee=
n eth0/1

thanks again for the pointer !

regards
Roland


-----Urspr=C3=BCngliche Nachricht-----
Von: "Roland Kletzing" <devzero@web.de>
Gesendet: 12.11.2011 19:50:33
An: "Julian Anastasov" <ja@ssi.bg>
Betreff: Re: send/receive data via eth0/1 external loop ?

>great, thanks!
>
>
>-----Urspr=C3=BCngliche Nachricht-----
>Von: "Julian Anastasov" <ja@ssi.bg>
>Gesendet: 12.11.2011 19:31:13
>An: "Roland Kletzing" <devzero@web.de>
>Betreff: Re: send/receive data via eth0/1 external loop ?
>
>>
>> Hello,
>>
>>On Sat, 12 Nov 2011, Roland Kletzing wrote:
>>
>>> Hello,
>>> i`m searching for a while now, but i did not find a solution, so fo=
rgive when
>>> i`m (as a user) asking for expert help here.
>>>
>>> I want to do some network stress/burn-in and quality/reliability te=
sting,
>>> i.e. i want to send/receive large amounts of data trough the system=
s network
>>> interfaces without the need of hogging the net or other systems.
>>>
>>> so, that test should run "loopback", i.e. connecting eth0+1 via cro=
ssover cable
>>> or via locally attached switch. I don`t want to use a second system=
 for that.
>>>
>>> testing at ip/tcp level would be favourable , but raw eth level wou=
ld be also fine.
>>>
>>> But how ?
>>> What appears simple on a first view, seems to be difficult.... :(
>>>
>>> All i came across is this report:
>>> http://www.zyztematik.com/?p=3D10
>>> and this description of a patch:
>>> http://www.ssi.bg/~ja/send-to-self.txt
>>>
>>> Does somebody know a proper way of achieving this without patching =
the
>>> kernel ?
>>
>> You can use accept_local flag and rule with pref 0:
>>
>>http://marc.info/?l=3Dlinux-netdev&m=3D125983955627148&w=3D2
>>
>>Regards
>>
>>--
>>Julian Anastasov <ja@ssi.bg>
>


___________________________________________________________
SMS schreiben mit WEB.DE FreeMail - einfach, schnell und
kostenguenstig. Jetzt gleich testen! http://f.web.de/?mc=3D021192
