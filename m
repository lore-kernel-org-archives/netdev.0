From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Thu, 24 Oct 2002 12:50:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021024125030.A7529@flint.arm.linux.org.uk>
References: <200210231218.18733.roy@karlsbakk.net> <200210231309.g9ND9Bp03373@Port.imtp.ilyichevsk.odessa.ua> <200210231536.24269.roy@karlsbakk.net> <200210241129.g9OBTpp09266@Port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200210241129.g9OBTpp09266@Port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Thu, Oct 24, 2002 at 02:22:25PM -0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 24, 2002 at 02:22:25PM -0200, Denis Vlasenko wrote:
> Please delete memory.o, rerun make bzImage, capture gcc
> command used for compiling memory.c, modify it:
> 
> gcc ... -o memory.o  ->  gcc ... -S -o memory.s ...

Have you tried make mm/memory.s ?

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html
