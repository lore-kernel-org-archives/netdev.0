From: Bob Wirka <bobwirka@rtcworks.com>
Subject: Re: NFS and Network Driver Question
Date: Thu, 21 Oct 2004 10:50:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4177DADF.7020006@rtcworks.com>
References: <41704198.8000206@rtcworks.com> <4175AEFE.7090002@rtcworks.com> <41768B15.1090402@osdl.org> <4177D115.5070205@rtcworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <4177D115.5070205@rtcworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Once again I beg forgiveness for mailing list clutter...

My problem was that I hadn't added a default route. My bad.

Thanks anyway.

Bob Wirka
Realtime Control Works

Bob Wirka wrote:

> Here is another wrinkle: The program on my embedded system cannot send 
> UDP broadcast messages when NFS mounted. When the system is booted 
> without NFS (using the DiskOnChip for root file system) I can send UDP 
> broadcasts. When the system is booted with NFS (using my laptop for 
> root file system) UDP broadcasts result in "Network unreachable" 
> errors, though it CAN send directed UDP messages and TCP messages.
>
> The kernel configuration is identical, except for kernel IP 
> autoconfiguration, root over nfs, and compiled-in network driver. The 
> NFS configuration on the host has 'no_root_squash', and <<now>> all 
> the files on the host root file system are owned by root.
>
> Any ideas?
>
> Thanks,
>
> Bob Wirka
> Realtime Control Works
>
> Stephen Hemminger wrote:
>
>> Bob Wirka wrote:
>>
>>> Ok, now I feel like I'm taking crazy pills...
>>>
>>> The embedded system boots up and mounts the root file system on my 
>>> host laptop. The 'rc.sysinit' startup script executes the command 
>>> 'mount -a' which should mount /proc, /dev/pts, and /dev/shm, as 
>>> listed in /etc/fstab. When executed, that command returns  "mount: 
>>> only root can do that".
>>>
>>> When I get to the bash prompt, 'whoami' reports that I am, indeed, 
>>> root. A 'mount -a' from the command prompt gives the same result; it 
>>> doesn't think I'm root for the mount command.
>>>
>>> I can chown a file owned by root to some other user, and I can 
>>> create a file or directory in a directory owned by root; so it 
>>> doesn't always think I'm not root.
>>>
>> Are you getting bit by the nfs uid mapping on the server. Is it 
>> mapping your local "root" to "nobody"
>> on the server?
>>
>
>
>
