From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: Sat, 8 Mar 2003 11:45:40 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303081132030.12316-100000@kenzo.iwr.uni-heidelberg.de>
References: <m1fzpylimr.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Russell King <rmk@arm.linux.org.uk>, Chris Dukes <pakrat@www.uk.linux.org>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
   Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1fzpylimr.fsf@frodo.biederman.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 7 Mar 2003, Eric W. Biederman wrote:

> Only because the implementations suck.  See etherboot.

Agreed, but as you rightly say at the end of your message...

> But sometimes you are stuck with what you can do.

... and you can't go use etherboot or whatever, you have to deal with it. 
You can deal with it today because ipconfig is small, you might not be 
able to deal with it tomorrow if you'll have to transfer twice as much 
because of a big initrd.

> But this is all before the kernel is loaded. 

But that's exactly my point. The ipconfig functionality is needed and what 
I ask for is that whatever means (if any) are chosen to replace it, they 
should keep the low size.

> Having booted a 1000 node cluster with TFTP and DHCP.

I do not doubt this, but I'm afraid that you (or we) might not be able to 
do it again tomorrow. And probably this is an ideal case where you have 
used the better solution as client (etherboot)...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
