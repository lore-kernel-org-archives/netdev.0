From: Christopher Chan <cchan@outblaze.com>
Subject: Re: High number of concurrent connections causes 2.6.4 to go berserk
Date: Fri, 02 Apr 2004 12:00:35 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406CE563.5090105@outblaze.com>
References: <406CBA60.50103@outblaze.com> <406CDDF5.4070500@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Yusuf Goolamabbas <yusufg@outblaze.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <406CDDF5.4070500@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> Christopher Chan wrote:
> 
>> When tcp_max_syn_backlog is set to 4096 and
>> route.max_size = 131072
>> route.gc_thresh = 65536
>>
>> the box goes berserk almost immediately after bootup due to a bounce 
>> flood hitting the box.
> 
> 
>> The below values seem to workaround whatever problem the kernel has.
>>
>> tcp_max_syn_backlog = 2048
>> route.max_size = 1048576
>> route.gc_thresh = 65536
> 
> 
> Did you try just one of the first two and see which
> one actually made a difference? I'm assuming the first,
> but that might not be the case..

Another box that has less traffic but sometimes gets ddosed by bounces 
has default settings

tcp_max_syn_backlog = 1024
route.max_size = 131072
route.gc_thresh = 8192

This box's 2.6.4 also went berserk during the ddos.

I'll try your suggestion and get back to you.

> 
> thanks,
> Nivedita
> 
> 
> 
