From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: High number of concurrent connections causes 2.6.4 to go berserk
Date: Thu, 01 Apr 2004 19:28:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406CDDF5.4070500@us.ibm.com>
References: <406CBA60.50103@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Yusuf Goolamabbas <yusufg@outblaze.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christopher Chan <cchan@outblaze.com>
In-Reply-To: <406CBA60.50103@outblaze.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christopher Chan wrote:

> When tcp_max_syn_backlog is set to 4096 and
> route.max_size = 131072
> route.gc_thresh = 65536
> 
> the box goes berserk almost immediately after bootup due to a bounce 
> flood hitting the box.

> The below values seem to workaround whatever problem the kernel has.
> 
> tcp_max_syn_backlog = 2048
> route.max_size = 1048576
> route.gc_thresh = 65536

Did you try just one of the first two and see which
one actually made a difference? I'm assuming the first,
but that might not be the case..

thanks,
Nivedita
