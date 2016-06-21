From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: Re: [PATCH v4 00/19] CALIPSO Implementation
Date: Tue, 21 Jun 2016 10:55:48 +0100
Message-ID: <20160621095548.GA19213@merlot.physics.ox.ac.uk>
References: <1466429819-12707-1-git-send-email-huw@codeweavers.com>
 <20160621.053928.1340819307282355897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160621.053928.1340819307282355897.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2016 at 05:39:28AM -0400, David Miller wrote:
> From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
> Date: Mon, 20 Jun 2016 14:36:40 +0100
> 
> > This patch series implements RFC 5570 - Common Architecture Label IPv6
> > Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
> > on IPv6 packets using a hop-by-hop option.  CALIPSO is very similar to
> > its IPv4 cousin CIPSO and much of this series is based on that code.
> 
> What tree do you expect to integrate this?

My understanding is that Paul Moore is happy to take them
in via the SELinux tree.  However, these patches do touch
some core networking code, such as the IPv6 option handling
code (in a similar manner to the way CIPSO touched the IPv4
option code), so if you have any comments on those aspects
that would be good to hear.

Thanks,
Huw.
_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
