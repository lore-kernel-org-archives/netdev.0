From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Fix 64bit bugs in dscc44.c II
Date: Wed, 8 Oct 2003 18:33:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008163345.GA28793@wotan.suse.de>
References: <20031007175953.GA1802@averell> <20031008084205.5c81faac.davem@redhat.com> <20031008155548.GB16937@wotan.suse.de> <20031008090132.2b58c067.davem@redhat.com> <20031008160859.GD16937@wotan.suse.de> <20031008161149.GA8134@wotan.suse.de> <20031008091050.11b2acb7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, ak@muc.de, ncorbic@sangoma.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031008091050.11b2acb7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 08, 2003 at 09:10:50AM -0700, David S. Miller wrote:
> > BTW my change fixed the warning.
> 
> I know, but it added a new one.
> 
> > It's somewhat ugly to store pointers in unsigned long I agree,
> 
> I have _NO_ problem with this, all I'm asking you to do is:
> 
> -	foo = ioremap_nocache(...);
> + 	foo = (unsigned long) ioremap_nocache(...);

Just do that then when you apply the patch. Would have been faster
than to write all these emails ;-)

-Andi
