From: bhartin@straus-frank.com
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Sun, 4 Apr 2004 18:57:20 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404041836100.6853@edp12.straus-frank.int>
References: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int>
 <20040126235559.A3832@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404041553010.6853@edp12.straus-frank.int>
 <20040405002028.A8125@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040405002028.A8125@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here are the results using this new patch:

No SMP, no ACPI:  Appears to work well--transferred about 8 gigs okay
With SMP, with ACPI:  Interface locks up after a few MB
With SMP, no ACPI:  Interface locks up after a few MB
No SMP, with ACPI:  Appears to work well--transferred about 8 gigs okay

My laptop is *finally* reaching full usability!  Thanks!

I can live without SMP--this is just a single P4/HT, so I'm not losing 
much.

Thanks again.  If there is any debugging info you need towards fixing the 
SMP compatibility issue, just let me know, but I'm not in a hurry for 
it.

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company
Thanks,

On Mon, 5 Apr 2004, Francois Romieu wrote:

> bhartin@straus-frank.com <bhartin@straus-frank.com> :
> [...]
> > I haven't tried your latest set of patches because I haven't been able to 
> > find the URL for them again (I got carried away cleaning up my bookmarks 
> > recently).  Let me know if there are any newer ones you'd like for me to 
> > try.
> 
> http://www.fr.zoreil.com/people/francois/misc/20040329-2.6.5-rc2-r8169.c-test.patch
> 
> It removes a possible loop in the Tx irq handler and should save some cpu
> cycles as well. Apply against 2.6.5.
> 
> --
> Ueimor
> 

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company
