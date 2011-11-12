From: "Roland Kletzing" <devzero@web.de>
Subject: Re: send/receive data via eth0/1 external loop ?
Date: Sat, 12 Nov 2011 19:50:33 +0100 (CET)
Message-ID: <795974251.12417.1321123833884.JavaMail.fmail@mwmweb006>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Julian Anastasov" <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate05.web.de ([217.72.192.243]:46962 "EHLO
	fmmailgate05.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab1KLSuf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 13:50:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

great, thanks!


-----Urspr=C3=BCngliche Nachricht-----
Von: "Julian Anastasov" <ja@ssi.bg>
Gesendet: 12.11.2011 19:31:13
An: "Roland Kletzing" <devzero@web.de>
Betreff: Re: send/receive data via eth0/1 external loop ?

>
> Hello,
>
>On Sat, 12 Nov 2011, Roland Kletzing wrote:
>
>> Hello,
>> i`m searching for a while now, but i did not find a solution, so for=
give when
>> i`m (as a user) asking for expert help here.
>>
>> I want to do some network stress/burn-in and quality/reliability tes=
ting,
>> i.e. i want to send/receive large amounts of data trough the systems=
 network
>> interfaces without the need of hogging the net or other systems.
>>
>> so, that test should run "loopback", i.e. connecting eth0+1 via cros=
sover cable
>> or via locally attached switch. I don`t want to use a second system =
for that.
>>
>> testing at ip/tcp level would be favourable , but raw eth level woul=
d be also fine.
>>
>> But how ?
>> What appears simple on a first view, seems to be difficult.... :(
>>
>> All i came across is this report:
>> http://www.zyztematik.com/?p=3D10
>> and this description of a patch:
>> http://www.ssi.bg/~ja/send-to-self.txt
>>
>> Does somebody know a proper way of achieving this without patching t=
he
>> kernel ?
>
> You can use accept_local flag and rule with pref 0:
>
>http://marc.info/?l=3Dlinux-netdev&m=3D125983955627148&w=3D2
>
>Regards
>
>--
>Julian Anastasov <ja@ssi.bg>


___________________________________________________________
SMS schreiben mit WEB.DE FreeMail - einfach, schnell und
kostenguenstig. Jetzt gleich testen! http://f.web.de/?mc=3D021192
