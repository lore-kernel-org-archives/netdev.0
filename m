From: Bob Wirka <bobwirka@rtcworks.com>
Subject: Re: NFS and Network Driver Question
Date: Wed, 20 Oct 2004 11:03:56 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41768C6C.6040102@rtcworks.com>
References: <41704198.8000206@rtcworks.com> <4175AEFE.7090002@rtcworks.com> <41768B15.1090402@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <41768B15.1090402@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

No, I was actually taking stupid pills. I had the setuid bit set on 
'mount', and it was owned by 'admin'. I had a number of files and 
directories owned by 'admin' so that I could ftp files in and out of the 
original target system (as admin). It bit me.

Everything seems to be working well now.

Best regards,

Bob Wirka
Realtime Control Works

Stephen Hemminger wrote:

> Bob Wirka wrote:
>
>> Ok, now I feel like I'm taking crazy pills...
>>
>> The embedded system boots up and mounts the root file system on my 
>> host laptop. The 'rc.sysinit' startup script executes the command 
>> 'mount -a' which should mount /proc, /dev/pts, and /dev/shm, as 
>> listed in /etc/fstab. When executed, that command returns  "mount: 
>> only root can do that".
>>
>> When I get to the bash prompt, 'whoami' reports that I am, indeed, 
>> root. A 'mount -a' from the command prompt gives the same result; it 
>> doesn't think I'm root for the mount command.
>>
>> I can chown a file owned by root to some other user, and I can create 
>> a file or directory in a directory owned by root; so it doesn't 
>> always think I'm not root.
>>
> Are you getting bit by the nfs uid mapping on the server. Is it 
> mapping your local "root" to "nobody"
> on the server?
>
