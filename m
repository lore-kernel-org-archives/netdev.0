From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: NFS and Network Driver Question
Date: Wed, 20 Oct 2004 08:58:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41768B15.1090402@osdl.org>
References: <41704198.8000206@rtcworks.com> <4175AEFE.7090002@rtcworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: no To-header on input <unlisted-recipients:;>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bob Wirka <bobwirka@rtcworks.com>
In-Reply-To: <4175AEFE.7090002@rtcworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bob Wirka wrote:

> Ok, now I feel like I'm taking crazy pills...
>
> The embedded system boots up and mounts the root file system on my 
> host laptop. The 'rc.sysinit' startup script executes the command 
> 'mount -a' which should mount /proc, /dev/pts, and /dev/shm, as listed 
> in /etc/fstab. When executed, that command returns  "mount: only root 
> can do that".
>
> When I get to the bash prompt, 'whoami' reports that I am, indeed, 
> root. A 'mount -a' from the command prompt gives the same result; it 
> doesn't think I'm root for the mount command.
>
> I can chown a file owned by root to some other user, and I can create 
> a file or directory in a directory owned by root; so it doesn't always 
> think I'm not root.
>
Are you getting bit by the nfs uid mapping on the server. Is it mapping 
your local "root" to "nobody"
on the server?
