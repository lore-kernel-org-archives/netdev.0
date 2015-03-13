From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: mmotm 2015-03-12-15-17 uploaded (rocker.c)
Date: Fri, 13 Mar 2015 09:06:11 -0700
Message-ID: <55030AF3.5070705@infradead.org>
References: <550210ac.Pr9rP4DS86Wiia6Q%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz,
	Jiri Pirko <jiri@resnulli.us>, sfeldma@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <550210ac.Pr9rP4DS86Wiia6Q%akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/12/15 15:18, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2015-03-12-15-17 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (3.x
> or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
> 

on i386:  found in mmotm but contained in linux-next:

when CONFIG_INET is not enabled:


drivers/built-in.o: In function `rocker_port_fib_ipv4.isra.55':
rocker.c:(.text+0x1ea5ae): undefined reference to `arp_tbl'
rocker.c:(.text+0x1ea6b1): undefined reference to `arp_tbl'
drivers/built-in.o: In function `rocker_netevent_event':
rocker.c:(.text+0x1ea7b8): undefined reference to `arp_tbl'



-- 
~Randy
