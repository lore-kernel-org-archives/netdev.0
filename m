From: Andi Kleen <ak@suse.de>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 02:20:07 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc3u3$f6a$2@main.gmane.org>
References: <20020521015407.A1296@wotan.suse.de> <200205210011.EAA04286@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, george@mvista.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200205210011.EAA04286@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2002 at 04:11:00AM +0400, A.N.Kuznetsov wrote:
> Hello!
> 
> > It's unfortunately the truth. Even in_interrupt() is buggy current 
> > on SMP preemptive.
> 
> And why folks working on preemtive kernel do not repair this?
> To all that I remember it is well known issue.

It is fixed on x86-64 @)

if [ "$CONFIG_SMP" = "n" ]; then
   bool 'Preemptible Kernel' CONFIG_PREEMPT
fi

-Andi
