From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: mlx4_core 0000:05:00.0: event 19 arrived
Date: Fri, 14 Jun 2013 15:47:09 -0500
Message-ID: <20130614204709.GC7310@sbohrermbp13-local.rgmadvisors.com>
References: <20130614155342.GA7310@sbohrermbp13-local.rgmadvisors.com>
 <20130614161003.GB7310@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZKAJMV6qY43zONh_82GcgW2NOrABHEqVzv4vp77Dy7xSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, amirv@mellanox.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:33283 "EHLO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751126Ab3FNUrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 16:47:12 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so1102534obb.39
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 13:47:12 -0700 (PDT)
In-Reply-To: <CAJZOPZKAJMV6qY43zONh_82GcgW2NOrABHEqVzv4vp77Dy7xSQ@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 10:58:48PM +0300, Or Gerlitz wrote:
> On Fri, Jun 14, 2013 at 7:10 PM, Shawn Bohrer <sbohrer@rgmadvisors.com> wrote:
> > I also just remembered that I had set debug_level=1 on mlx4_core and
> > that is likely why I am now seeing these messages.  If these messages
> > are expected and harmless then I'll simply turn off the debug messages.
> 
> probably harmless, but let me check after the weekend and get back to
> you. So you are using only mlx4_en, correct? no IPoIB nor user space
> of your own that deal with QPs, SRQs (Shared Receive Queues) or alike

Actually, I'm receiving UDP multicast using standard sockets, and
occasionally sending multicast UD RoCE.  So in this case we are
managing some of our own QPs and SRQs.  I just reproduced this and see
these messages when I stop my app(s).  My guess is that they come from
the RoCE side of things since I was running a purely UDP workload
earlier and stopping/starting and never saw any of these.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
