From: Bob Wirka <bobwirka@rtcworks.com>
Subject: Re: NFS and Network Driver Question
Date: Wed, 20 Oct 2004 10:47:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4176887F.3030406@rtcworks.com>
References: <41704198.8000206@rtcworks.com>  <4175AEFE.7090002@rtcworks.com> <7126.1098233641@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------060600040306010000040906"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <7126.1098233641@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060600040306010000040906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Yes, you are correct; thank you.

So now I've got an embedded x86 system that boots from a (detachable) 
floppy drive to the root file system on my laptop host. Syslinux works 
very well for the boot disk function.

This system is very cool; it will be used to initialize new units in 
production, and for providing a platform for easy debugging of applications.

The lessons learned here will also be used on the embedded ARM projects.

Thanks again to all who have helped.

Best regards,

Bob Wirka
Realtime Control Works

Michael Richardson wrote:

>-----BEGIN PGP SIGNED MESSAGE-----
>
>
>  
>
>>>>>>"Bob" == Bob Wirka <bobwirka@rtcworks.com> writes:
>>>>>>            
>>>>>>
>    Bob> Ok, now I feel like I'm taking crazy pills...
>
>    Bob> The embedded system boots up and mounts the root file system on
>    Bob> my host laptop. The 'rc.sysinit' startup script executes the
>    Bob> command 'mount -a' which should mount /proc, /dev/pts, and
>    Bob> /dev/shm, as listed in /etc/fstab. When executed, that command
>    Bob> returns "mount: only root can do that".
>
>    Bob> When I get to the bash prompt, 'whoami' reports that I am,
>    Bob> indeed, root. A 'mount -a' from the command prompt gives the
>    Bob> same result; it doesn't think I'm root for the mount command.
>
>  The mount command is perhaps setuid root, but you aren't mounting the
>root file system in a way that permits it to be identified as such.
>  Or, the file is in fact not owned by root, and is in fact setuid not-root.
>
>- --
>]     "Elmo went to the wrong fundraiser" - The Simpson         |  firewalls  [
>]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
>] mcr@xelerance.com      http://www.sandelman.ottawa.on.ca/mcr/ |device driver[
>] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [
>-----BEGIN PGP SIGNATURE-----
>Version: GnuPG v1.2.2 (GNU/Linux)
>Comment: Finger me for keys
>
>iQCVAwUBQXW3KIqHRg3pndX9AQFERwQAhUpzaFDzVch+W2TEU2SFDtSJZObQ5yZ3
>7hhVtiDI5igzO/MHkipXm89LrNnfwSg+6jfMIo8MlWU+nuqHFWiHkrPeWj8jaFmd
>QQ+aHhryTn06fyU4UQg1OjEpcHHvo4pLr8lqPwebMjL2JKgk8CM/X2d1N6m9xT+2
>Nx8H0Rq84sM=
>=Dso2
>-----END PGP SIGNATURE-----
>
>
>  
>


--------------060600040306010000040906
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
Yes, you are correct; thank you.<br>
<br>
So now I've got an embedded x86 system that boots from a (detachable)
floppy drive to the root file system on my laptop host. Syslinux works
very well for the boot disk function.<br>
<br>
This system is very cool; it will be used to initialize new units in
production, and for providing a platform for easy debugging of
applications.<br>
<br>
The lessons learned here will also be used on the embedded ARM projects.<br>
<br>
Thanks again to all who have helped.<br>
<br>
Best regards,<br>
<br>
Bob Wirka<br>
Realtime Control Works<br>
<br>
Michael Richardson wrote:<br>
<blockquote cite="mid7126.1098233641@marajade.sandelman.ottawa.on.ca"
 type="cite">
  <pre wrap="">-----BEGIN PGP SIGNED MESSAGE-----


  </pre>
  <blockquote type="cite">
    <blockquote type="cite">
      <blockquote type="cite">
        <blockquote type="cite">
          <blockquote type="cite">
            <pre wrap="">"Bob" == Bob Wirka <a class="moz-txt-link-rfc2396E" href="mailto:bobwirka@rtcworks.com">&lt;bobwirka@rtcworks.com&gt;</a> writes:
            </pre>
          </blockquote>
        </blockquote>
      </blockquote>
    </blockquote>
  </blockquote>
  <pre wrap=""><!---->    Bob&gt; Ok, now I feel like I'm taking crazy pills...

    Bob&gt; The embedded system boots up and mounts the root file system on
    Bob&gt; my host laptop. The 'rc.sysinit' startup script executes the
    Bob&gt; command 'mount -a' which should mount /proc, /dev/pts, and
    Bob&gt; /dev/shm, as listed in /etc/fstab. When executed, that command
    Bob&gt; returns "mount: only root can do that".

    Bob&gt; When I get to the bash prompt, 'whoami' reports that I am,
    Bob&gt; indeed, root. A 'mount -a' from the command prompt gives the
    Bob&gt; same result; it doesn't think I'm root for the mount command.

  The mount command is perhaps setuid root, but you aren't mounting the
root file system in a way that permits it to be identified as such.
  Or, the file is in fact not owned by root, and is in fact setuid not-root.

- --
]     "Elmo went to the wrong fundraiser" - The Simpson         |  firewalls  [
]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
] <a class="moz-txt-link-abbreviated" href="mailto:mcr@xelerance.com">mcr@xelerance.com</a>      <a class="moz-txt-link-freetext" href="http://www.sandelman.ottawa.on.ca/mcr/">http://www.sandelman.ottawa.on.ca/mcr/</a> |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Finger me for keys

iQCVAwUBQXW3KIqHRg3pndX9AQFERwQAhUpzaFDzVch+W2TEU2SFDtSJZObQ5yZ3
7hhVtiDI5igzO/MHkipXm89LrNnfwSg+6jfMIo8MlWU+nuqHFWiHkrPeWj8jaFmd
QQ+aHhryTn06fyU4UQg1OjEpcHHvo4pLr8lqPwebMjL2JKgk8CM/X2d1N6m9xT+2
Nx8H0Rq84sM=
=Dso2
-----END PGP SIGNATURE-----


  </pre>
</blockquote>
<br>
</body>
</html>

--------------060600040306010000040906--
