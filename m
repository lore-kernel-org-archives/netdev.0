From: "markes\.albert\@libero\.it" <markes.albert@libero.it>
Subject: Re: Net module Realtek 8110S/8169S
Date: Sun, 28 Mar 2004 20:54:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <HVAV6J$519DA0EE0F55619EB1C716E4E68CA99E@libero.it>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="_=__=_XaM3_.1080500059.2A.755759.42.26105.52.42.007.14947"
Cc: "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "romieu" <romieu@fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--_=__=_XaM3_.1080500059.2A.755759.42.26105.52.42.007.14947
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Francois
    after your e-mail, I redo the test with kernel 2.6.4-van=
illa unchanged and
in console mode (without X) I have no problem. I don'=
t understand because the
problem some day ago raise in console and with =
X. In my test the problem raise
always when I copy file in KDE to PC by =
smbclient. So I think the problem was X
but with kernel 2.6.3 the proble=
m don't raise. The system hang and the only
option is hardware-reset, no=
thing ping not respond and led do not change nay more.
   I do the thing=
 you told me with kernel unchanged
   dd if=3D/dev/hda  of=3D/dev/null b=
s=3D1024k.... go well
   dd if=3D/myfile of=3D/newfile ok
   transfer (=
console) ok
   
   Retry with X
   transfer KO

   I recompile kerne=
l as you told me.
> Processor type and features  --->
> [...]
>   x x[=
 ] Symmetric multi-processing support                               x x  =
 
>   x x[ ] Preemptible Kernel                                         =
      x x   
>   x x[*] Local APIC support on uniprocessors             =
                 x x   
> 
> Enable as well:
> 
> Kernel hacking  ---=
>
> [...]
>   x x            [*] Magic SysRq key                       =
               x x   
  retray test with KDE and the problem don't raise=
.

When the problem raised I saw in the kernel-changelog change in modu=
le r8169 so
I thoungh the problem was NIC-module, the only change from t=
wo configuration.
Now I only raise the problem (without your change) wit=
h KDE... I don't
understand if is NIC or X-KDE problem.
Can you help me=
 to find who hang my system?

I attach dmeg and lspci

Thanks a lot=0D
=
Alberto Marchesini



--_=__=_XaM3_.1080500059.2A.755759.42.26105.52.42.007.14947
Content-Type: application/x-gzip;
	name="=?iso-8859-1?Q?message.tar.gz?="
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="=?iso-8859-1?Q?message.tar.gz?="

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
oRzKoRzKoRzKoRzKoRzKoXzW8l8LNg+gAFAAAA==

--_=__=_XaM3_.1080500059.2A.755759.42.26105.52.42.007.14947--
