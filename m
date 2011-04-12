From: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 33102] New: File's copied from client->linux
 server only copy 1st 64K data; rest is lost
Date: Mon, 11 Apr 2011 19:06:55 -0500
Message-ID: <BANLkTimW4HPquU_2a400ECviSPPcrfxoCA@mail.gmail.com>
References: <bug-33102-10286@https.bugzilla.kernel.org/>
	<20110411152431.a5997005.akpm@linux-foundation.org>
	<4DA3839B.1050102@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
To: Linda Walsh <lkml-gT3AUAsYRbTYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DA3839B.1050102-gT3AUAsYRbTYtjvyW6yDsg@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2011 at 5:41 PM, Linda Walsh <lkml-gT3AUAsYRbTYtjvyW6yDsg@public.gmane.org> wrote:
>
> Andrew Morton wrote:
>>
>> (switched to email. =A0Please respond via emailed reply-to-all, not =
via the
>> bugzilla web interface).
>>
>> On Mon, 11 Apr 2011 22:12:41 GMT
>> bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
>>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D33102
>>>
>>> =A0 =A0 =A0 =A0 =A0 Summary: File's copied from client->linux serve=
r only copy 1st
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A064K data;rest is lost
>>> =A0 =A0 =A0 =A0 =A0 Product: Networking
>>> =A0 =A0 =A0 =A0 =A0 Version: 2.5
>>> =A0 =A0Kernel Version: 2.6.38.2
>>> =A0 =A0 =A0 =A0 =A0Platform: All
>>> =A0 =A0 =A0 =A0OS/Version: Linux
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0Tree: Mainline
>>> =A0 =A0 =A0 =A0 =A0 =A0Status: NEW
>>> =A0 =A0 =A0 =A0 =A0Severity: blocking
>>> =A0 =A0 =A0 =A0 =A0Priority: P1
>>> =A0 =A0 =A0 =A0 Component: IPV4
>>> =A0 =A0 =A0 =A0AssignedTo: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
>>> =A0 =A0 =A0 =A0ReportedBy: lkml-gT3AUAsYRbTYtjvyW6yDsg@public.gmane.org
>>> =A0 =A0 =A0 =A0Regression: Yes
>>>
>>
>> Seems to be a 2.6.37->2.6.38 regression.
>>
>> ----------
>
> Not exactly -- Please note -- I tried both 2.6.38(.0) and 2.6.38.1.
>
> They both work.

Any chance that we could get a wireshark trace of the failure?

https://wiki.samba.org/index.php/Capture_Packets

gives instructions.   There may also be useful information on
network stack failures returned in the samba log
(often named smbd.log).



--=20
Thanks,

Steve
