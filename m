From: "Tong Lee" <leetong311@hotmail.com>
Subject: An answer for "Scheduling in interrupt".
Date: Tue, 09 Jul 2002 09:48:42 +0800
Sender: owner-netdev@oss.sgi.com
Message-ID: <F14A97ZjvVtwBNIYBhZ0000cbef@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


Dear Krishna Kumar,

I have finally figured our what caused the "Scheduling in interrupt" pani=
c.=20
I didn't realize that ip_local_deliver is run within the bottom_half=20
context, and I had used a semaphore there. It is that semaphore which had=
=20
induced a sleep and therefore a schedule.

However I now have a new problem to fight with: my kgdb became=20
dysfunctional. Upon reaching a "return" statement and when I typed "next"=
,=20
it simply went off and never returned! Have you any comments on how to=20
solve or bypass this problem?

Lee Tong


_________________________________________________________________
=D3=EB=C1=AA=BB=FA=B5=C4=C5=F3=D3=D1=BD=F8=D0=D0=BD=BB=C1=F7=A3=AC=C7=EB=CA=
=B9=D3=C3 MSN Messenger:=20
http://messenger.microsoft.com/cn/
